import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Douglas-Peucker 轨迹降采样
/// 自适应 ε：根据 bounding box 和 zoom level 动态调整
class PolylineSimplifier {
  /// 对轨迹点做 Douglas-Peucker 简化
  /// [points] 原始轨迹点
  /// [zoom] 当前地图 zoom level（用于自适应 ε）
  /// 返回简化后的点（保留首尾）
  static List<LatLng> simplify(List<LatLng> points, {double zoom = 15}) {
    if (points.length <= 2) return List.of(points);

    final epsilon = _adaptiveEpsilon(points, zoom);
    return _douglasPeucker(points, epsilon);
  }

  /// 带速度信息的简化（热力轨迹用）
  /// 热力轨迹需要更多点来显示颜色渐变，因此简化策略比普通轨迹更保守：
  /// - 点数 ≤ 2000：不简化，flutter_map 可轻松处理
  /// - 点数 > 2000：使用均匀降采样到 1500 点（保留首尾 + 等间距采样），
  ///   比 Douglas-Peucker 更适合热力场景（保持颜色分布均匀）
  static List<({LatLng point, double speed})> simplifyWithSpeed(
    List<LatLng> points,
    List<double> speeds, {
    double zoom = 15,
  }) {
    if (points.length != speeds.length) {
      return List.generate(
        points.length,
        (i) => (point: points[i], speed: i < speeds.length ? speeds[i] : 0),
      );
    }

    // 2000 点以下不简化（flutter_map 渲染无压力）
    if (points.length <= 2000) {
      return List.generate(
        points.length,
        (i) => (point: points[i], speed: speeds[i]),
      );
    }

    // 超过 2000 点：均匀降采样到 1500 点
    const target = 1500;
    // 点数已在目标范围内，无需采样，直接返回
    if (points.length <= target) {
      return List.generate(
        points.length,
        (i) => (point: points[i], speed: speeds[i]),
      );
    }
    final step = (points.length - 1) / (target - 1);
    final result = <({LatLng point, double speed})>[];
    for (int j = 0; j < target - 1; j++) {
      final i = (j * step).round();
      result.add((point: points[i], speed: speeds[i]));
    }
    // 确保最后一个点
    result.add((point: points.last, speed: speeds.last));
    return result;
  }

  /// 自适应 ε 策略
  /// - 计算 bounding box 对角线长度
  /// - ε = 对角线 × 系数（zoom 越大，系数越小）
  static double _adaptiveEpsilon(List<LatLng> points, double zoom) {
    final bbox = _boundingBox(points);
    final diagonal = _haversineMeters(
      bbox.southWest.latitude, bbox.southWest.longitude,
      bbox.northEast.latitude, bbox.northEast.longitude,
    );

    // 基础系数：zoom 15 约 0.0001，zoom 18 约 0.00001
    // 操场绕圈（bbox 小）→ diagonal 小 → ε 小 → 保留更多细节
    // 越野（bbox 大）→ diagonal 大 → ε 大 → 适度简化
    final zoomFactor = pow(2, 18 - zoom) * 0.00001;
    final epsilon = diagonal * zoomFactor;

    // 下限极小值确保操场绕圈（bbox ~200m）时保留圆弧细节
    // 上限防止 zoom 很低时 ε 过大导致只剩首尾
    return epsilon.clamp(0.0000001, 0.01);
  }

  /// Douglas-Peucker 递归实现
  static List<LatLng> _douglasPeucker(List<LatLng> points, double epsilon) {
    if (points.length <= 2) return List.of(points);

    // 找到离首尾连线最远的点
    double maxDist = 0;
    int maxIndex = 0;
    final first = points.first;
    final last = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], first, last);
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    if (maxDist > epsilon) {
      // 递归简化两半
      final left = _douglasPeucker(points.sublist(0, maxIndex + 1), epsilon);
      final right = _douglasPeucker(points.sublist(maxIndex), epsilon);
      // 合并（去掉右半部分的第一个点，因为它就是 maxIndex 点）
      return [...left, ...right.skip(1)];
    } else {
      // 所有中间点都在容差内，只保留首尾
      return [first, last];
    }
  }

  /// 点到线段的垂直距离（使用经纬度近似计算）
  static double _perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final dx = lineEnd.longitude - lineStart.longitude;
    final dy = lineEnd.latitude - lineStart.latitude;

    if (dx == 0 && dy == 0) {
      // 线段退化为点，使用度数空间欧几里得距离，与主逻辑单位一致
      final dLat = point.latitude - lineStart.latitude;
      final dLng = point.longitude - lineStart.longitude;
      return sqrt(dLat * dLat + dLng * dLng);
    }

    // 将经纬度差值归一化处理
    final t = ((point.longitude - lineStart.longitude) * dx +
            (point.latitude - lineStart.latitude) * dy) /
        (dx * dx + dy * dy);
    final tClamped = t.clamp(0.0, 1.0);

    final projLat = lineStart.latitude + tClamped * dy;
    final projLng = lineStart.longitude + tClamped * dx;

    // 用度数差作为距离度量（同一区域内足够精确）
    final dLat = point.latitude - projLat;
    final dLng = point.longitude - projLng;
    return sqrt(dLat * dLat + dLng * dLng);
  }

  /// Bounding box
  static _BBox _boundingBox(List<LatLng> points) {
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return _BBox(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// Haversine 距离（米）
  static double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}

class _BBox {
  final LatLng southWest;
  final LatLng northEast;
  const _BBox(this.southWest, this.northEast);
}
