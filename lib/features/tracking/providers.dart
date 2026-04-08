import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart' show runSessionDaoProvider, routePointDaoProvider, splitPaceDaoProvider, achievementDaoProvider, audienceUnlockDaoProvider;
import '../../../shared/services/tts_service.dart';
import 'data/checkpoint_service.dart';
import 'data/location_service.dart';
import 'data/tracking_persistence.dart';
import 'domain/run_finalizer.dart';
import 'presentation/tracking_notifier.dart';
import 'presentation/tracking_state.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final checkpointServiceProvider = Provider<CheckpointService>((ref) {
  return CheckpointService();
});

final trackingPersistenceProvider = Provider<TrackingPersistence>((ref) {
  return TrackingPersistence(
    runSessionDao: ref.read(runSessionDaoProvider),
    routePointDao: ref.read(routePointDaoProvider),
    splitPaceDao: ref.read(splitPaceDaoProvider),
    checkpointService: ref.read(checkpointServiceProvider),
  );
});

final runFinalizerProvider = Provider<RunFinalizer>((ref) {
  return RunFinalizer(
    runSessionDao: ref.read(runSessionDaoProvider),
    routePointDao: ref.read(routePointDaoProvider),
    achievementDao: ref.read(achievementDaoProvider),
    audienceUnlockDao: ref.read(audienceUnlockDaoProvider),
  );
});

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(
    ref.read(locationServiceProvider),
    ref.read(runSessionDaoProvider),
    ref.read(ttsServiceProvider),
    ref.read(trackingPersistenceProvider),
    ref.read(runFinalizerProvider),
  );
});
