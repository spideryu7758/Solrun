import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/tracking/domain/pace_calculator.dart';

void main() {
  late PaceCalculator calculator;

  setUp(() {
    calculator = PaceCalculator();
  });

  group('PaceCalculator 距离计算', () {
    test('首个点不产生距离', () {
      final delta = calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      expect(delta, 0);
      expect(calculator.totalDistanceMeters, 0);
    });

    test('两个点之间计算距离', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      final delta = calculator.addPoint(_point(lat: 39.901, lng: 116.4, ts: 3));
      expect(delta, greaterThan(0));
      expect(calculator.totalDistanceMeters, delta);
    });

    test('多个点累计距离', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.901, lng: 116.4, ts: 3));
      final d2 = calculator.totalDistanceMeters;
      calculator.addPoint(_point(lat: 39.902, lng: 116.4, ts: 6));
      expect(calculator.totalDistanceMeters, greaterThan(d2));
    });
  });

  group('PaceCalculator 实时配速', () {
    test('不足 2 个点返回 null', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      expect(calculator.currentPaceSecPerKm, isNull);
    });

    test('速度为 0（原地不动）返回 null', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 3));
      expect(calculator.currentPaceSecPerKm, isNull);
    });

    test('正常跑步返回合理配速', () {
      // 模拟 5 min/km 的跑步（约 3.33 m/s）
      // 每 3 秒前进约 10m（纬度约 0.00009）
      for (int i = 0; i <= 30; i += 3) {
        calculator.addPoint(_point(lat: 39.9 + i * 0.00003, lng: 116.4, ts: i));
      }
      final pace = calculator.currentPaceSecPerKm;
      expect(pace, isNotNull);
      // 配速应在合理范围内（180-600 秒/公里，即 3-10 min/km）
      expect(pace!, greaterThan(100));
      expect(pace, lessThan(1000));
    });

    test('30 秒窗口超时后旧点被移除', () {
      // 添加一些早期点
      for (int i = 0; i <= 9; i += 3) {
        calculator.addPoint(_point(lat: 39.9 + i * 0.00003, lng: 116.4, ts: i));
      }
      // 添加 35 秒后的点（前面的点应该被移除出窗口）
      calculator.addPoint(_point(lat: 39.91, lng: 116.4, ts: 35));
      calculator.addPoint(_point(lat: 39.911, lng: 116.4, ts: 38));
      // 应该仍然能计算配速
      expect(calculator.currentPaceSecPerKm, isNotNull);
    });
  });

  group('PaceCalculator 分公里配速', () {
    test('未达 1km 时无 split', () {
      for (int i = 0; i <= 30; i += 3) {
        calculator.addPoint(_point(lat: 39.9 + i * 0.00003, lng: 116.4, ts: i));
      }
      expect(calculator.splits, isEmpty);
      expect(calculator.completedKms, 0);
    });

    test('跨过 1km 产生 split', () {
      // 每个点间距约 111m（纬度差 0.001），需要约 10 个点达到 1km
      for (int i = 0; i <= 10; i++) {
        calculator.addPoint(
          _point(
            lat: 39.9 + i * 0.001,
            lng: 116.4,
            ts: i * 3, // 保持在 GPS 断流阈值内
          ),
        );
      }
      expect(calculator.completedKms, greaterThanOrEqualTo(1));
      expect(calculator.splits, isNotEmpty);
      expect(calculator.splits.first.kmIndex, 1);
      expect(calculator.splits.first.paceSecPerKm, greaterThan(0));
    });

    test('finishLastSplit 处理部分公里', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(
        _point(lat: 39.905, lng: 116.4, ts: 6),
      ); // ~555m，保持连续采样
      final lastSplit = calculator.finishLastSplit(
        DateTime.fromMillisecondsSinceEpoch(150000),
      );
      expect(lastSplit, isNotNull);
      expect(lastSplit!.kmIndex, 1); // 第一公里（未完成）
    });

    test('excludePausedDuration 从分公里耗时中扣除暂停时间', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.905, lng: 116.4, ts: 6));

      calculator.excludePausedDuration(const Duration(seconds: 30));

      final lastSplit = calculator.finishLastSplit(
        DateTime.fromMillisecondsSinceEpoch(150000),
      );

      expect(lastSplit, isNotNull);
      expect(lastSplit!.endTime.difference(lastSplit.startTime).inSeconds, 120);
    });

    test('clearRealtimeWindow 避免恢复后累计暂停段跳点距离', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.901, lng: 116.4, ts: 3));
      final distanceBeforePause = calculator.totalDistanceMeters;

      calculator.clearRealtimeWindow();
      final deltaAfterResume = calculator.addPoint(
        _point(lat: 39.905, lng: 116.4, ts: 6),
      );

      expect(deltaAfterResume, 0);
      expect(calculator.totalDistanceMeters, distanceBeforePause);
    });

    test('seedRealtimeWindow 保留恢复后的第一段移动距离', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.901, lng: 116.4, ts: 3));
      final distanceBeforePause = calculator.totalDistanceMeters;

      calculator.clearRealtimeWindow();
      calculator.seedRealtimeWindow(_point(lat: 39.905, lng: 116.4, ts: 30));
      final deltaAfterResume = calculator.addPoint(
        _point(lat: 39.906, lng: 116.4, ts: 33),
      );

      expect(deltaAfterResume, greaterThan(100));
      expect(
        calculator.totalDistanceMeters,
        closeTo(distanceBeforePause + deltaAfterResume, 0.001),
      );
    });

    test('reset 清除所有状态', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      calculator.addPoint(_point(lat: 39.91, lng: 116.4, ts: 60));
      calculator.reset();
      expect(calculator.totalDistanceMeters, 0);
      expect(calculator.completedKms, 0);
      expect(calculator.splits, isEmpty);
      expect(calculator.currentPaceSecPerKm, isNull);
    });
  });

  group('Haversine 距离验证', () {
    test('同一点距离为 0', () {
      calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 0));
      final delta = calculator.addPoint(_point(lat: 39.9, lng: 116.4, ts: 3));
      expect(delta, 0);
    });

    test('已知距离校验（1度纬度约 111km）', () {
      calculator.addPoint(_point(lat: 39.0, lng: 116.4, ts: 0));
      final delta = calculator.addPoint(_point(lat: 40.0, lng: 116.4, ts: 3));
      // 1 度纬度 ≈ 111,000m，允许 1% 误差
      expect(delta, closeTo(111000, 1200));
    });
  });
}

/// 辅助方法：创建测试用 TrackPoint
TrackPoint _point({
  required double lat,
  required double lng,
  required int ts, // 秒
  double speed = 3.0,
  double accuracy = 5.0,
}) {
  return TrackPoint(
    latitude: lat,
    longitude: lng,
    accuracy: accuracy,
    speed: speed,
    timestamp: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
  );
}
