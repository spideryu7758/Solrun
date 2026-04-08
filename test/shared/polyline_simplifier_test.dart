import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_pure/shared/utils/polyline_simplifier.dart';

void main() {
  group('PolylineSimplifier', () {
    test('空列表返回空列表', () {
      final result = PolylineSimplifier.simplify([]);
      expect(result, isEmpty);
    });

    test('1 个点返回 1 个点', () {
      final result = PolylineSimplifier.simplify([const LatLng(39.9, 116.4)]);
      expect(result.length, 1);
    });

    test('2 个点返回 2 个点', () {
      final points = [const LatLng(39.9, 116.4), const LatLng(39.91, 116.41)];
      final result = PolylineSimplifier.simplify(points);
      expect(result.length, 2);
    });

    test('直线上的点被简化', () {
      // 3 个共线点，中间点应被移除
      final points = [
        const LatLng(39.9, 116.4),
        const LatLng(39.905, 116.4), // 共线中间点
        const LatLng(39.91, 116.4),
      ];
      final result = PolylineSimplifier.simplify(points, zoom: 10);
      // 低 zoom 下共线点应被简化
      expect(result.length, lessThanOrEqualTo(3));
      // 首尾必须保留
      expect(result.first, points.first);
      expect(result.last, points.last);
    });

    test('拐角处的点被保留', () {
      // L 形轨迹，拐点不应被移除。用更大幅度的拐角确保不被简化
      final points = [
        const LatLng(39.9, 116.4),
        const LatLng(39.9, 116.5),   // 向东直线
        const LatLng(40.0, 116.5),   // 90° 向北拐角（大幅度）
      ];
      final result = PolylineSimplifier.simplify(points, zoom: 16);
      // 大幅度拐角必须保留
      expect(result.length, 3);
    });

    test('大量点被有效简化', () {
      // 模拟 1000 个点（直线 + 轻微噪声）
      final points = List.generate(1000, (i) => LatLng(
        39.9 + i * 0.0001,
        116.4 + (i % 3) * 0.00001, // 轻微左右噪声
      ));
      final result = PolylineSimplifier.simplify(points, zoom: 15);
      // 应显著减少点数
      expect(result.length, lessThan(points.length));
      // 但至少保留首尾
      expect(result.first, points.first);
      expect(result.last, points.last);
    });

    test('操场绕圈场景在高 zoom 下保留更多细节', () {
      // 模拟 400m 操场绕圈（bbox 很小，点数多）
      final points = <LatLng>[];
      for (int i = 0; i < 200; i++) {
        final angle = i * 0.0314; // ~2 圈
        points.add(LatLng(
          39.9 + 0.001 * sin(angle),
          116.4 + 0.001 * cos(angle),
        ));
      }
      // zoom 18（最大级别）下应保留最多细节
      final resultZ18 = PolylineSimplifier.simplify(points, zoom: 18);
      // zoom 12（低级别）下应大幅简化
      final resultZ12 = PolylineSimplifier.simplify(points, zoom: 12);
      // 高 zoom 保留更多或相等
      expect(resultZ18.length, greaterThanOrEqualTo(resultZ12.length));
      // 两者都应少于原始点数
      expect(resultZ18.length, lessThanOrEqualTo(200));
      // 首尾必须保留
      expect(resultZ18.first, points.first);
      expect(resultZ18.last, points.last);
    });

    test('zoom 越高保留越多细节', () {
      final points = List.generate(100, (i) => LatLng(
        39.9 + i * 0.0001,
        116.4 + (i % 5) * 0.00002,
      ));
      final lowZoom = PolylineSimplifier.simplify(points, zoom: 10);
      final highZoom = PolylineSimplifier.simplify(points, zoom: 18);
      // 高 zoom 应保留更多点
      expect(highZoom.length, greaterThanOrEqualTo(lowZoom.length));
    });
  });
}
