import 'package:flutter/painting.dart';

import '../../../data/database.dart';
import '../../tracking/domain/elevation_calculator.dart';
import '../../../shared/utils/pace_color_mapper.dart';

/// 分享卡片不可变数据（在打开分享页时一次性预计算）
class ShareCardData {
  final RunSession session;
  final List<RoutePoint> points;
  final List<SplitPace> splits;
  final String nickname;
  final String? avatarPath;

  // 预计算
  final List<double> speeds;
  final List<Color> segmentColors;
  final List<({List<int> indices, Color color})> mergedSegments;
  final List<double> altitudes;
  final double recalculatedElevationGain; // 从轨迹点重新计算的海拔爬升
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  // 城市和天气信息（从数据库读取）
  final String? city;
  final String? weather;

  ShareCardData({
    required this.session,
    required this.points,
    required this.splits,
    required this.nickname,
    this.avatarPath,
    required this.speeds,
    required this.segmentColors,
    required this.mergedSegments,
    required this.altitudes,
    required this.recalculatedElevationGain,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    this.city,
    this.weather,
  });

  /// 从原始数据构建（预计算所有衍生字段）
  /// 对轨迹点降采样（最多 500 点），避免渲染爆内存
  factory ShareCardData.build({
    required RunSession session,
    required List<RoutePoint> points,
    required List<SplitPace> splits,
    required String nickname,
    String? avatarPath,
    String? cityOverride,
    String? weatherOverride,
  }) {
    // 从全量轨迹点重新计算海拔爬升（修复历史记录中 0 的问题）
    final elevGain = _recalculateElevation(points);

    // 降采样：分享卡片最多 500 点足够
    final sampled = _downsample(points, 500);
    final speeds = sampled.map((p) => p.speed).toList();
    final segmentColors = PaceColorMapper.mapSegmentColors(speeds);
    final mergedSegments = PaceColorMapper.mergeSegments(segmentColors);
    final altitudes = sampled
        .where((p) => p.altitude != null)
        .map((p) => p.altitude!)
        .toList();

    // 计算 bounding box（用降采样后的点）
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in sampled) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return ShareCardData(
      session: session,
      points: sampled,
      splits: splits,
      nickname: nickname,
      avatarPath: avatarPath,
      speeds: speeds,
      segmentColors: segmentColors,
      mergedSegments: mergedSegments,
      altitudes: altitudes,
      recalculatedElevationGain: elevGain,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
      city: cityOverride ?? session.city,
      weather: weatherOverride ?? session.weather,
    );
  }

  /// 从轨迹点重新计算累计爬升
  /// 复用 ElevationCalculator 的保守算法，避免分享页与结果页口径分叉。
  static double _recalculateElevation(List<RoutePoint> points) {
    return ElevationCalculator.calculateGain(points.map((p) => p.altitude));
  }

  /// 均匀降采样，保留首尾点
  static List<RoutePoint> _downsample(List<RoutePoint> points, int maxCount) {
    if (points.length <= maxCount) return points;
    final step = points.length / maxCount;
    final result = <RoutePoint>[];
    for (int i = 0; i < maxCount; i++) {
      result.add(points[(i * step).floor().clamp(0, points.length - 1)]);
    }
    // 确保最后一个点
    if (result.last != points.last) result.add(points.last);
    return result;
  }

  /// 格式化的距离 (km)
  String get distanceKm => (session.distanceMeters / 1000).toStringAsFixed(2);

  /// 格式化的配速
  String get paceFormatted => formatPaceSeconds(session.avgPaceSecPerKm);

  /// 数据娱乐化配速：分钟永久显示为 5，超出的分钟折算进秒数。
  String get entertainmentPaceFormatted =>
      formatPaceSeconds(session.avgPaceSecPerKm, dataEntertainment: true);

  static String formatPaceSeconds(
    int paceSecPerKm, {
    bool dataEntertainment = false,
  }) {
    final min = dataEntertainment ? 5 : paceSecPerKm ~/ 60;
    final sec = dataEntertainment
        ? entertainmentPaceExtraSeconds(paceSecPerKm)
        : paceSecPerKm % 60;
    return '$min\'${sec.toString().padLeft(2, '0')}"';
  }

  static int entertainmentPaceExtraSeconds(int paceSecPerKm) {
    return (paceSecPerKm - 5 * 60).clamp(0, 1 << 31);
  }

  static int entertainmentPaceDisplaySeconds(int paceSecPerKm) {
    return 5 * 60 + entertainmentPaceExtraSeconds(paceSecPerKm);
  }

  /// 格式化的时长
  String get durationFormatted {
    final h = session.durationSeconds ~/ 3600;
    final m = (session.durationSeconds % 3600) ~/ 60;
    final s = session.durationSeconds % 60;
    if (h > 0) {
      return '${h}h${m.toString().padLeft(2, '0')}\'${s.toString().padLeft(2, '0')}"';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 格式化的日期
  String get dateFormatted {
    final t = session.startTime;
    return '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// 卡路里
  String get caloriesFormatted => '${session.caloriesKcal} kcal';

  /// 海拔使用数据库值。结束跑步会先保存 GPS fallback，在线补全后再写入 DEM 结果。
  double get elevationGain => session.elevationGainMeters;

  String get elevationFormatted => '${elevationGain.toStringAsFixed(0)} m';
}
