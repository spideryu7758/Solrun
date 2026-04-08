import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/shared/utils/pace_color_mapper.dart';

void main() {
  group('PaceColorMapper', () {
    group('mapSegmentColors', () {
      test('空列表返回空列表', () {
        final result = PaceColorMapper.mapSegmentColors([]);
        expect(result, isEmpty);
      });

      test('单元素列表返回空列表（至少需要两个点才能形成一段）', () {
        final result = PaceColorMapper.mapSegmentColors([3.0]);
        expect(result, isEmpty);
      });

      test('两个点返回一个颜色', () {
        final result = PaceColorMapper.mapSegmentColors([3.0, 4.0]);
        expect(result.length, equals(1));
      });

      test('N 个点返回 N-1 个颜色', () {
        final speeds = [2.0, 3.0, 4.0, 5.0, 6.0];
        final result = PaceColorMapper.mapSegmentColors(speeds);
        expect(result.length, equals(4));
      });

      test('全部静止速度（< 0.5 m/s）→ 返回红色列表', () {
        // 所有速度低于 stationaryThreshold，validSpeeds 为空
        // 代码中 validSpeeds.isEmpty 分支返回红色 0xFFFF4444
        final speeds = [0.1, 0.2, 0.3, 0.4];
        final result = PaceColorMapper.mapSegmentColors(speeds);

        expect(result.length, equals(3));
        for (final color in result) {
          expect(color, equals(const Color(0xFFFF4444)));
        }
      });

      test('混合静止和运动速度 → 静止段为灰色', () {
        // 前两个点静止，后两个运动
        final speeds = [0.1, 0.2, 3.0, 4.0];
        final result = PaceColorMapper.mapSegmentColors(speeds);

        expect(result.length, equals(3));
        // 第一段：avg(0.1, 0.2) = 0.15 < 0.5 → 灰色
        expect(result[0], equals(PaceColorMapper.stationaryColor));
      });

      test('单一速度（均匀） → 所有段同色', () {
        // 所有速度相同时 p10 == p90，t = 0.5
        final speeds = [3.0, 3.0, 3.0, 3.0, 3.0];
        final result = PaceColorMapper.mapSegmentColors(speeds);

        expect(result.length, equals(4));
        final firstColor = result[0];
        for (final color in result) {
          expect(color.toARGB32(), equals(firstColor.toARGB32()));
        }
      });

      test('正常速度分布 → 颜色种类 > 1', () {
        // 构造一组有明显速度差异的点
        final speeds = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0];
        final result = PaceColorMapper.mapSegmentColors(speeds);

        expect(result.length, equals(7));
        // 应有多种颜色（不全相同）
        final uniqueColors = result.map((c) => c.toARGB32()).toSet();
        expect(uniqueColors.length, greaterThan(1));
      });

      test('颜色数不超过 colorLevels + 1（含灰色）', () {
        // 生成 100 个不同速度
        final speeds = List.generate(100, (i) => 1.0 + i * 0.1);
        final result = PaceColorMapper.mapSegmentColors(speeds);

        final uniqueColors = result.map((c) => c.toARGB32()).toSet();
        // 最多 16 级量化 + 1 灰色
        expect(uniqueColors.length, lessThanOrEqualTo(PaceColorMapper.colorLevels + 1));
      });
    });

    group('mergeSegments', () {
      test('空列表返回空列表', () {
        final result = PaceColorMapper.mergeSegments([]);
        expect(result, isEmpty);
      });

      test('单个颜色返回一个段', () {
        final colors = [const Color(0xFFFF0000)];
        final result = PaceColorMapper.mergeSegments(colors);

        expect(result.length, equals(1));
        expect(result[0].color, equals(const Color(0xFFFF0000)));
      });

      test('相邻同色合并为一段', () {
        final red = const Color(0xFFFF0000);
        final colors = [red, red, red];
        final result = PaceColorMapper.mergeSegments(colors);

        expect(result.length, equals(1));
        expect(result[0].color, equals(red));
      });

      test('不同颜色各成一段', () {
        final red = const Color(0xFFFF0000);
        final green = const Color(0xFF00FF00);
        final blue = const Color(0xFF0000FF);
        final colors = [red, green, blue];
        final result = PaceColorMapper.mergeSegments(colors);

        expect(result.length, equals(3));
        expect(result[0].color, equals(red));
        expect(result[1].color, equals(green));
        expect(result[2].color, equals(blue));
      });

      test('交替颜色正确分段', () {
        final red = const Color(0xFFFF0000);
        final green = const Color(0xFF00FF00);
        final colors = [red, red, green, green, red];
        final result = PaceColorMapper.mergeSegments(colors);

        expect(result.length, equals(3));
        expect(result[0].color, equals(red));
        expect(result[1].color, equals(green));
        expect(result[2].color, equals(red));
      });

      test('合并后段的 indices 保证连续性（首尾相接）', () {
        final red = const Color(0xFFFF0000);
        final green = const Color(0xFF00FF00);
        final colors = [red, red, green, green];
        final result = PaceColorMapper.mergeSegments(colors);

        expect(result.length, equals(2));
        // 第一段末尾 index = 第二段起始 index
        expect(result[0].indices.last, equals(result[1].indices.first));
      });
    });
  });
}
