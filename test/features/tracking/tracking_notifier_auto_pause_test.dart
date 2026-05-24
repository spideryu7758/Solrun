import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/data/daos/achievement_dao.dart';
import 'package:run_pure/data/daos/audience_unlock_dao.dart';
import 'package:run_pure/data/daos/route_point_dao.dart';
import 'package:run_pure/data/daos/run_session_dao.dart';
import 'package:run_pure/data/daos/split_pace_dao.dart';
import 'package:run_pure/data/database.dart';
import 'package:run_pure/features/tracking/data/checkpoint_service.dart';
import 'package:run_pure/features/tracking/data/location_service.dart';
import 'package:run_pure/features/tracking/data/step_cadence_service.dart';
import 'package:run_pure/features/tracking/data/tracking_persistence.dart';
import 'package:run_pure/features/tracking/domain/pace_calculator.dart';
import 'package:run_pure/features/tracking/domain/run_finalizer.dart';
import 'package:run_pure/features/tracking/presentation/tracking_notifier.dart';
import 'package:run_pure/features/tracking/presentation/tracking_state.dart';
import 'package:run_pure/shared/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeTrackingPersistence persistence;
  late TrackingNotifier notifier;
  late DateTime currentTime;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    persistence = FakeTrackingPersistence(db);
    currentTime = _time(0);
    notifier = TrackingNotifier(
      FakeLocationService(),
      FakeStepCadenceService(),
      RunSessionDao(db),
      TtsService(),
      persistence,
      FakeRunFinalizer(db),
      now: () => currentTime,
    );
    notifier.configureForTesting(startTime: _time(0), sessionId: 1);
  });

  tearDown(() async {
    notifier.dispose();
    await db.close();
  });

  test('pending auto-pause canceled flushes candidate points', () {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    expect(notifier.state.totalPointCount, 1);

    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.002, speed: 3),
    );

    expect(notifier.state.status, TrackingStatus.running);
    expect(notifier.state.totalPointCount, 3);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [
      _time(0),
      _time(3),
      _time(6),
    ]);
    expect(notifier.state.distanceMeters, greaterThan(100));
  });

  test('confirmed auto-pause drops candidate point and backfills duration', () {
    currentTime = _time(0);
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );

    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.durationSeconds, 3);
    expect(notifier.state.totalPointCount, 1);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [_time(0)]);
  });

  test(
    'endRun while pause is pending drops candidate and saves backfilled time',
    () async {
      notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));
      notifier.handleGpsPointForTesting(
        _point(ts: 3, latOffset: 0.001, speed: 0.1),
      );

      currentTime = _time(8);
      final result = await notifier.endRun();

      expect(result.durationSeconds, 3);
      expect(persistence.savedDurationSeconds, 3);
      expect(persistence.flushedPoints.map((p) => p.timestamp), [_time(0)]);
    },
  );

  test('endRun while autoPaused does not add paused wall time', () async {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );
    expect(notifier.state.durationSeconds, 3);

    currentTime = _time(20);
    final result = await notifier.endRun();

    expect(result.durationSeconds, 3);
    expect(persistence.savedDurationSeconds, 3);
  });

  test(
    'manual pause while auto-pause pending flushes candidates and clears detector',
    () async {
      notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));
      notifier.handleGpsPointForTesting(
        _point(ts: 3, latOffset: 0.001, speed: 0.1),
      );

      expect(notifier.state.totalPointCount, 1);

      currentTime = _time(4);
      notifier.pauseRun();

      expect(notifier.state.status, TrackingStatus.paused);
      expect(notifier.state.totalPointCount, 2);
      expect(persistence.loggedPoints.map((p) => p.timestamp), [
        _time(0),
        _time(3),
      ]);

      currentTime = _time(8);
      final result = await notifier.endRun();

      expect(result.durationSeconds, 0);
      expect(persistence.savedDurationSeconds, 0);
      expect(persistence.flushedPoints.map((p) => p.timestamp), [
        _time(0),
        _time(3),
      ]);
    },
  );

  test('single resume spike stays autoPaused and drops candidate point', () {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);

    currentTime = _time(9);
    notifier.handleGpsPointForTesting(
      _point(ts: 9, latOffset: 0.001, speed: 0.9),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.totalPointCount, 1);

    currentTime = _time(12);
    notifier.handleGpsPointForTesting(
      _point(ts: 12, latOffset: 0.001, speed: 0.1),
    );

    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.totalPointCount, 1);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [_time(0)]);
  });

  test('confirmed resume replays candidate movement points', () {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);

    currentTime = _time(9);
    notifier.handleGpsPointForTesting(
      _point(ts: 9, latOffset: 0.001, speed: 0.9),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);

    currentTime = _time(12);
    notifier.handleGpsPointForTesting(
      _point(ts: 12, latOffset: 0.002, speed: 0.9),
    );

    expect(notifier.state.status, TrackingStatus.running);
    expect(notifier.state.durationSeconds, 6);
    expect(notifier.state.totalPointCount, 3);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [
      _time(0),
      _time(9),
      _time(12),
    ]);
    expect(notifier.state.distanceMeters, greaterThan(100));
  });

  test('confirmed resume counts movement from first resumed candidate', () {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);

    currentTime = _time(9);
    notifier.handleGpsPointForTesting(
      _point(ts: 9, latOffset: 0.005, speed: 0.9),
    );

    currentTime = _time(12);
    notifier.handleGpsPointForTesting(
      _point(ts: 12, latOffset: 0.006, speed: 0.9),
    );

    expect(notifier.state.status, TrackingStatus.running);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [
      _time(0),
      _time(9),
      _time(12),
    ]);
    expect(notifier.state.distanceMeters, greaterThan(100));
    expect(notifier.state.distanceMeters, lessThan(300));
  });

  test('gps displacement requires confirmation before resume', () {
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(3);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(6);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );
    expect(notifier.state.status, TrackingStatus.autoPaused);

    currentTime = _time(12);
    notifier.handleGpsPointForTesting(
      _point(ts: 12, latOffset: 0.002, speed: 0.1),
    );

    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.totalPointCount, 1);

    currentTime = _time(15);
    notifier.handleGpsPointForTesting(
      _point(ts: 15, latOffset: 0.003, speed: 0.1),
    );

    expect(notifier.state.status, TrackingStatus.running);
    expect(notifier.state.durationSeconds, 6);
    expect(notifier.state.totalPointCount, 3);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [
      _time(0),
      _time(12),
      _time(15),
    ]);
    expect(notifier.state.distanceMeters, greaterThan(100));
    expect(notifier.state.distanceMeters, lessThan(130));
  });

  test(
    'endRun while resume is pending saves confirmed candidate movement',
    () async {
      notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

      currentTime = _time(3);
      notifier.handleGpsPointForTesting(
        _point(ts: 3, latOffset: 0.001, speed: 0.1),
      );

      currentTime = _time(6);
      notifier.handleGpsPointForTesting(
        _point(ts: 6, latOffset: 0.001, speed: 0.1),
      );
      expect(notifier.state.status, TrackingStatus.autoPaused);

      currentTime = _time(9);
      notifier.handleGpsPointForTesting(
        _point(ts: 9, latOffset: 0.002, speed: 0.9),
      );

      currentTime = _time(11);
      notifier.handleGpsPointForTesting(
        _point(ts: 11, latOffset: 0.003, speed: 0.9),
      );
      expect(notifier.state.status, TrackingStatus.autoPaused);

      currentTime = _time(12);
      final result = await notifier.endRun();

      expect(result.durationSeconds, 6);
      expect(persistence.savedDurationSeconds, 6);
      expect(persistence.loggedPoints.map((p) => p.timestamp), [
        _time(0),
        _time(9),
        _time(11),
      ]);
      expect(persistence.flushedPoints.map((p) => p.timestamp), [
        _time(0),
        _time(9),
        _time(11),
      ]);
      expect(result.distanceMeters, greaterThan(100));
      expect(result.distanceMeters, lessThan(130));
    },
  );

  test('delayed auto-pause callback uses gps sample timestamps', () {
    notifier.configureForTesting(
      startTime: _time(0),
      sessionId: 1,
      autoPauseEnabled: true,
    );

    currentTime = _time(0);
    notifier.handleGpsPointForTesting(_point(ts: 0, latOffset: 0, speed: 3));

    currentTime = _time(30);
    notifier.handleGpsPointForTesting(
      _point(ts: 3, latOffset: 0.001, speed: 0.1),
    );

    currentTime = _time(31);
    notifier.handleGpsPointForTesting(
      _point(ts: 6, latOffset: 0.001, speed: 0.1),
    );

    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.durationSeconds, 3);

    currentTime = _time(40);
    notifier.handleGpsPointForTesting(
      _point(ts: 9, latOffset: 0.002, speed: 0.9),
    );

    currentTime = _time(41);
    notifier.handleGpsPointForTesting(
      _point(ts: 12, latOffset: 0.003, speed: 0.9),
    );

    expect(notifier.state.status, TrackingStatus.running);
    expect(notifier.state.durationSeconds, 6);
    expect(persistence.loggedPoints.map((p) => p.timestamp), [
      _time(0),
      _time(9),
      _time(12),
    ]);
    expect(notifier.state.distanceMeters, greaterThan(100));
    expect(notifier.state.distanceMeters, lessThan(130));
  });

  test('cadence remains trusted until stale threshold, then backfills', () {
    notifier.configureForTesting(
      startTime: _time(0),
      sessionId: 1,
      cadenceSensorAvailable: true,
      currentCadenceSpm: 80,
      lastStepAt: _time(0),
    );

    currentTime = _time(4);
    notifier.handleGpsPointForTesting(_point(ts: 4, latOffset: 0, speed: 0.35));

    expect(notifier.state.status, TrackingStatus.running);
    expect(notifier.state.totalPointCount, 1);

    currentTime = _time(7);
    notifier.handleGpsPointForTesting(_point(ts: 7, latOffset: 0, speed: 0.35));

    expect(notifier.state.status, TrackingStatus.autoPaused);
    expect(notifier.state.durationSeconds, 3);
    expect(notifier.state.totalPointCount, 1);
  });
}

DateTime _time(int seconds) =>
    DateTime(2026, 1, 1).add(Duration(seconds: seconds));

TrackPoint _point({
  required int ts,
  required double latOffset,
  required double speed,
}) {
  return TrackPoint(
    latitude: 39.9 + latOffset,
    longitude: 116.4,
    accuracy: 5,
    speed: speed,
    timestamp: _time(ts),
  );
}

class FakeLocationService extends LocationService {
  @override
  Stream<TrackPoint> get trackPointStream => const Stream<TrackPoint>.empty();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startTracking({bool isPaused = false}) async {}

  @override
  Future<void> updateInterval({required bool isPaused}) async {}

  @override
  Future<void> stopTracking() async {}

  @override
  Future<void> forceStop() async {}
}

class FakeStepCadenceService extends StepCadenceService {
  @override
  Stream<CadenceSample> get cadenceStream =>
      const Stream<CadenceSample>.empty();

  @override
  Future<bool> start() async => false;

  @override
  Future<void> stop() async {}
}

class FakeTrackingPersistence extends TrackingPersistence {
  final List<TrackPoint> loggedPoints = [];
  final List<TrackPoint> flushedPoints = [];
  int? savedDurationSeconds;

  FakeTrackingPersistence(AppDatabase db)
    : super(
        runSessionDao: RunSessionDao(db),
        routePointDao: RoutePointDao(db),
        splitPaceDao: SplitPaceDao(db),
        checkpointService: CheckpointService(),
      );

  @override
  Future<int> flushPointBuffer({
    required List<TrackPoint> buffer,
    required int sessionId,
    required int flushedCount,
  }) async {
    flushedPoints.addAll(buffer);
    return buffer.length;
  }

  @override
  Future<void> appendPointToLog(TrackPoint point, int orderIndex) async {
    loggedPoints.add(point);
  }

  @override
  Future<void> saveSession({
    required int sessionId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSeconds,
    required double distanceMeters,
    required int avgPace,
    required int bestPace,
    required int caloriesKcal,
    required double elevationGainMeters,
    required String autoName,
    required String? city,
    required String? weather,
    required List<SplitPaceData> splits,
  }) async {
    savedDurationSeconds = durationSeconds;
  }

  @override
  Future<void> deleteCheckpoint() async {}

  @override
  Future<void> updateSessionEnrichment({
    required int sessionId,
    required double elevationGainMeters,
    required String fallbackAutoName,
    required String enrichedAutoName,
    required String? city,
    required String? weather,
  }) async {}
}

class FakeRunFinalizer extends RunFinalizer {
  FakeRunFinalizer(AppDatabase db)
    : super(
        runSessionDao: RunSessionDao(db),
        routePointDao: RoutePointDao(db),
        achievementDao: AchievementDao(db),
        audienceUnlockDao: AudienceUnlockDao(db),
      );

  @override
  Future<FinalizeResult> fetchCityAndWeather({
    required int sessionId,
    required String lang,
  }) async {
    return const FinalizeResult();
  }

  @override
  Future<double> calculateElevationGain({
    required int sessionId,
    required double gpsFallbackMeters,
  }) async {
    return gpsFallbackMeters;
  }

  @override
  Future<void> checkAchievements({
    required int sessionId,
    required double distanceMeters,
    required int durationSeconds,
    required int avgPaceSecPerKm,
  }) async {}

  @override
  Future<void> checkAudienceUnlocks() async {}
}
