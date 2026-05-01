import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/tracking/domain/elevation_calculator.dart';

void main() {
  late ElevationCalculator calculator;

  setUp(() {
    calculator = ElevationCalculator();
  });

  group('ElevationCalculator', () {
    test('无海拔数据返回 0', () {
      calculator.addAltitude(null);
      calculator.addAltitude(null);
      calculator.finish();
      expect(calculator.totalGainMeters, 0);
    });

    test('平坦路面返回 0', () {
      for (int i = 0; i < 20; i++) {
        calculator.addAltitude(100.0);
      }
      calculator.finish();
      expect(calculator.totalGainMeters, 0);
    });

    test('持续上坡正确累计', () {
      // 模拟从 100m 爬到 120m（每次 +1m，20 个点）
      for (int i = 0; i < 20; i++) {
        calculator.addAltitude(100.0 + i);
      }
      calculator.finish();
      // 中位数滤波 + 保守阈值会导致首尾几个点丢失，但仍应识别持续爬升
      expect(calculator.totalGainMeters, greaterThan(10));
      expect(calculator.totalGainMeters, lessThan(25));
    });

    test('持续下坡不累计', () {
      for (int i = 0; i < 20; i++) {
        calculator.addAltitude(120.0 - i);
      }
      calculator.finish();
      expect(calculator.totalGainMeters, 0);
    });

    test('上下坡交替只累计上坡部分', () {
      // 100 → 110（+10）→ 105（-5）→ 115（+10）
      final alts = [
        100,
        102,
        104,
        106,
        108,
        110,
        108,
        106,
        105,
        107,
        109,
        111,
        113,
        115,
      ];
      for (final a in alts) {
        calculator.addAltitude(a.toDouble());
      }
      calculator.finish();
      // 总爬升应约为 10 + 10 = 20m（有滤波误差）
      expect(calculator.totalGainMeters, greaterThan(5));
    });

    test('小于 5m 的微小波动被过滤', () {
      // 100 → 104 → 100 → 104 反复，每次波动 < 保守阈值
      for (int i = 0; i < 20; i++) {
        calculator.addAltitude(100.0 + (i.isEven ? 0 : 4));
      }
      calculator.finish();
      expect(calculator.totalGainMeters, 0);
    });

    test('GPS 噪声尖刺被中位数滤波消除', () {
      // 稳定 100m，中间插入一个 150m 的尖刺
      final alts = [100, 100, 100, 150, 100, 100, 100, 100, 100, 100];
      for (final a in alts) {
        calculator.addAltitude(a.toDouble());
      }
      calculator.finish();
      // 中位数滤波应消除 150m 的尖刺，总爬升应为 0
      expect(calculator.totalGainMeters, 0);
    });

    test('明显垂直跳变被过滤', () {
      final alts = [
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        140,
        141,
        142,
        143,
        144,
        145,
      ];
      for (final a in alts) {
        calculator.addAltitude(a.toDouble());
      }
      calculator.finish();
      expect(calculator.totalGainMeters, 0);
    });

    test('静态 calculateGain 与实例计算一致', () {
      final alts = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110];
      final direct = ElevationCalculator.calculateGain(
        alts.map((a) => a.toDouble()),
      );
      for (final a in alts) {
        calculator.addAltitude(a.toDouble());
      }
      calculator.finish();
      expect(direct, calculator.totalGainMeters);
    });

    test('reset 清除所有状态', () {
      for (int i = 0; i < 20; i++) {
        calculator.addAltitude(100.0 + i);
      }
      calculator.finish();
      expect(calculator.totalGainMeters, greaterThan(0));

      calculator.reset();
      expect(calculator.totalGainMeters, 0);
    });
  });
}
