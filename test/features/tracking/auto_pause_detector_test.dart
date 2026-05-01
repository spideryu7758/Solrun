import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/tracking/domain/auto_pause_detector.dart';

void main() {
  late AutoPauseDetector detector;

  setUp(() {
    detector = AutoPauseDetector();
  });

  group('AutoPauseDetector 暂停触发', () {
    test('初始状态未暂停', () {
      expect(detector.isPaused, false);
    });

    test('速度低于阈值但不足 5 秒不触发', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      // 连续 4 秒低速
      for (int i = 0; i < 4; i++) {
        final event = detector.update(0.1, t0.add(Duration(seconds: i)));
        expect(event, isNull);
      }
      expect(detector.isPaused, false);
    });

    test('速度低于阈值持续 5 秒触发暂停', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      AutoPauseEvent? lastEvent;
      for (int i = 0; i <= 5; i++) {
        lastEvent = detector.update(0.1, t0.add(Duration(seconds: i)));
      }
      expect(lastEvent, AutoPauseEvent.paused);
      expect(detector.isPaused, true);
    });

    test('速度恰好等于 1.0 km/h (0.278 m/s) 不触发', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      // 0.278 m/s = 1.0 km/h，不低于阈值（< 0.278 才触发）
      AutoPauseEvent? lastEvent;
      for (int i = 0; i <= 6; i++) {
        lastEvent = detector.update(0.278, t0.add(Duration(seconds: i)));
      }
      // 0.278 恰好等于阈值，不满足 < 条件，不应触发
      expect(detector.isPaused, false);
      expect(lastEvent, isNull);
    });

    test('速度刚低于 1.0 km/h (0.277 m/s) 持续 5 秒触发', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      AutoPauseEvent? lastEvent;
      for (int i = 0; i <= 5; i++) {
        lastEvent = detector.update(0.277, t0.add(Duration(seconds: i)));
      }
      expect(lastEvent, AutoPauseEvent.paused);
      expect(detector.isPaused, true);
    });
  });

  group('AutoPauseDetector 恢复', () {
    test('暂停后速度超过 1.5 km/h 恢复', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      // 先触发暂停
      for (int i = 0; i <= 5; i++) {
        detector.update(0.1, t0.add(Duration(seconds: i)));
      }
      expect(detector.isPaused, true);

      // 速度恢复到 1.5 km/h 以上 (0.42 m/s)
      final event = detector.update(0.5, t0.add(const Duration(seconds: 8)));
      expect(event, AutoPauseEvent.resumed);
      expect(detector.isPaused, false);
    });

    test('暂停后速度恰好 0.417 m/s (1.5 km/h) 不恢复', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(0.1, t0.add(Duration(seconds: i)));
      }
      expect(detector.isPaused, true);

      // 0.417 m/s = 1.5 km/h，不满足 > 条件
      final event = detector.update(0.417, t0.add(const Duration(seconds: 8)));
      expect(event, isNull);
      expect(detector.isPaused, true);
    });

    test('暂停后速度刚超过 1.5 km/h (0.418 m/s) 恢复', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(0.1, t0.add(Duration(seconds: i)));
      }

      final event = detector.update(0.418, t0.add(const Duration(seconds: 8)));
      expect(event, AutoPauseEvent.resumed);
      expect(detector.isPaused, false);
    });
  });

  group('AutoPauseDetector 步频辅助', () {
    test('有步频数据时停步 5 秒触发暂停，即使 GPS 轻微漂移', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      AutoPauseEvent? lastEvent;
      for (int i = 0; i <= 5; i++) {
        lastEvent = detector.update(
          0.35,
          t0.add(Duration(seconds: i)),
          cadenceSpm: 0,
        );
      }
      expect(lastEvent, AutoPauseEvent.paused);
      expect(detector.isPaused, true);
    });

    test('有步频数据时低速但仍在走动不暂停', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 6; i++) {
        detector.update(0.1, t0.add(Duration(seconds: i)), cadenceSpm: 80);
      }
      expect(detector.isPaused, false);
    });

    test('低步频时 GPS 明确移动会否决暂停', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(0.8, t0.add(Duration(seconds: i)), cadenceSpm: 0);
      }
      expect(detector.isPaused, false);
    });

    test('自动暂停后步频或 GPS 明确移动都可恢复', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(0.35, t0.add(Duration(seconds: i)), cadenceSpm: 0);
      }
      expect(detector.isPaused, true);

      final driftEvent = detector.update(
        0.3,
        t0.add(const Duration(seconds: 8)),
        cadenceSpm: 0,
      );
      expect(driftEvent, isNull);
      expect(detector.isPaused, true);

      final gpsEvent = detector.update(
        0.8,
        t0.add(const Duration(seconds: 10)),
        cadenceSpm: 0,
      );
      expect(gpsEvent, AutoPauseEvent.resumed);
      expect(detector.isPaused, false);

      detector.reset();
      for (int i = 0; i <= 5; i++) {
        detector.update(0.35, t0.add(Duration(seconds: i)), cadenceSpm: 0);
      }
      final stepEvent = detector.update(
        0.1,
        t0.add(const Duration(seconds: 12)),
        cadenceSpm: 30,
      );
      expect(stepEvent, AutoPauseEvent.resumed);
      expect(detector.isPaused, false);
    });
  });

  group('AutoPauseDetector GPS 位移辅助', () {
    test('无步频时 GPS 速度漂移但近期位移很小也会暂停', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      AutoPauseEvent? lastEvent;
      for (int i = 0; i <= 5; i++) {
        lastEvent = detector.update(
          0.5,
          t0.add(Duration(seconds: i)),
          recentDisplacementMeters: 2.0,
          accuracyMeters: 8.0,
        );
      }
      expect(lastEvent, AutoPauseEvent.paused);
      expect(detector.isPaused, true);
    });

    test('无步频时 GPS 精度差则不使用小位移暂停判断', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 6; i++) {
        detector.update(
          0.5,
          t0.add(Duration(seconds: i)),
          recentDisplacementMeters: 2.0,
          accuracyMeters: 50.0,
        );
      }
      expect(detector.isPaused, false);
    });

    test('自动暂停后 GPS 位移恢复可触发恢复', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(
          0.5,
          t0.add(Duration(seconds: i)),
          recentDisplacementMeters: 2.0,
          accuracyMeters: 8.0,
        );
      }
      expect(detector.isPaused, true);

      final event = detector.update(
        0.1,
        t0.add(const Duration(seconds: 8)),
        recentDisplacementMeters: 10.0,
        accuracyMeters: 8.0,
      );
      expect(event, AutoPauseEvent.resumed);
      expect(detector.isPaused, false);
    });
  });

  group('AutoPauseDetector 震荡', () {
    test('速度在阈值附近快速震荡不误触发', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      // 交替高低速，每次不超过 5 秒
      for (int i = 0; i < 20; i++) {
        final speed = i.isEven ? 0.1 : 0.5; // 低 → 高 → 低 → 高
        detector.update(speed, t0.add(Duration(seconds: i)));
      }
      // 因为每次低速只持续 1 秒就被高速打断，不应触发
      expect(detector.isPaused, false);
    });
  });

  group('AutoPauseDetector reset', () {
    test('reset 清除所有状态', () {
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      for (int i = 0; i <= 5; i++) {
        detector.update(0.1, t0.add(Duration(seconds: i)));
      }
      expect(detector.isPaused, true);

      detector.reset();
      expect(detector.isPaused, false);
    });
  });
}
