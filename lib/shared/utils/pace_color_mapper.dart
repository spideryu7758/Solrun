import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// 配速→颜色映射
/// 将速度值映射到红(慢)→黄(中)→绿(快)渐变色
class PaceColorMapper {
  /// 颜色量化级数（合并相邻同色段减少 Polyline 数量）
  static const int colorLevels = 16;

  /// 静止/暂停段速度阈值 (m/s)，低于此值视为非运动状态
  static const double stationaryThreshold = 0.5;

  /// 静止/暂停段显示颜色（灰色）
  static const Color stationaryColor = Color(0xFF666666);

  /// 计算每段轨迹的颜色
  /// [speeds] 每个点的速度 (m/s)
  /// 返回 N-1 个颜色（每对相邻点之间一个颜色）
  static List<Color> mapSegmentColors(List<double> speeds) {
    if (speeds.length < 2) return [];

    // 收集有效速度（过滤静止段）
    final validSpeeds = speeds.where((s) => s >= stationaryThreshold).toList();
    if (validSpeeds.isEmpty) {
      return List.filled(speeds.length - 1, const Color(0xFFFF4444));
    }

    // 百分位归一化：p10 为慢速边界，p90 为快速边界
    validSpeeds.sort();
    final p10 = _percentile(validSpeeds, 10);
    final p90 = _percentile(validSpeeds, 90);

    final colors = <Color>[];
    for (int i = 0; i < speeds.length - 1; i++) {
      // 取相邻两点的平均速度
      final avgSpeed = (speeds[i] + speeds[i + 1]) / 2;

      if (avgSpeed < stationaryThreshold) {
        // 静止/暂停段：灰色
        colors.add(stationaryColor);
        continue;
      }

      // 归一化到 [0, 1]，0=慢 1=快
      double t;
      if (p90 <= p10) {
        t = 0.5; // 速度几乎一致
      } else {
        t = ((avgSpeed - p10) / (p90 - p10)).clamp(0.0, 1.0);
      }

      // 量化到 colorLevels 级
      final level = (t * (colorLevels - 1)).round();
      t = level / (colorLevels - 1);

      colors.add(_speedToColor(t));
    }

    return colors;
  }

  /// t ∈ [0,1]：0=慢(红) → 0.5=中(黄) → 1=快(绿)
  /// 使用 HSL 色相插值：H=0(红) → H=60(黄) → H=120(绿)
  static Color _speedToColor(double t) {
    final hue = t * 120; // 0°→120°
    // 固定饱和度和亮度，确保在深色底图上醒目
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.55).toColor();
  }

  /// 百分位计算
  static double _percentile(List<double> sorted, int p) {
    final index = (sorted.length - 1) * p / 100;
    final lower = index.floor();
    final upper = math.min(index.ceil(), sorted.length - 1);
    if (lower == upper) return sorted[lower];
    final frac = index - lower;
    return sorted[lower] * (1 - frac) + sorted[upper] * frac;
  }

  /// 将带颜色的线段合并相邻同色段，减少 Polyline 数量
  /// 返回合并后的段列表：每段包含点列表和颜色
  static List<({List<int> indices, Color color})> mergeSegments(List<Color> segmentColors) {
    if (segmentColors.isEmpty) return [];

    final result = <({List<int> indices, Color color})>[];
    var currentColor = segmentColors[0];
    var currentIndices = <int>[0];

    for (int i = 1; i < segmentColors.length; i++) {
      if (segmentColors[i].toARGB32() == currentColor.toARGB32()) {
        // 同色，扩展当前段
        currentIndices.add(i);
      } else {
        // 颜色变化，结束当前段
        currentIndices.add(i); // 末点也加入
        result.add((indices: currentIndices, color: currentColor));
        // 开始新段（从当前点开始，保证连续性）
        currentColor = segmentColors[i];
        currentIndices = <int>[i];
      }
    }
    // 最后一段
    currentIndices.add(segmentColors.length);
    result.add((indices: currentIndices, color: currentColor));

    return result;
  }
}
