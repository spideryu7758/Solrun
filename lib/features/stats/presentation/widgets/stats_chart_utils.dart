import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// 统计图表通用工具函数

/// 计算 Y 轴间隔（约 3-4 个刻度）
///
/// [ceilMax] 为经过放大后的最大值，根据不同数量级返回合适的间隔。
/// [thresholds] 为 (上限, 间隔) 对，从小到大排列，超出所有上限时使用最后一个间隔。
double calcYInterval(double ceilMax, List<(double, double)> thresholds) {
  for (final (limit, interval) in thresholds) {
    if (ceilMax <= limit) return interval;
  }
  return thresholds.last.$2;
}

/// 通用柱状图触摸提示配置
BarTouchData buildBarTouchData({
  required BuildContext context,
  required String Function(int index, double value) formatTooltip,
}) {
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        if (rod.toY <= 0) return null;
        return BarTooltipItem(
          formatTooltip(group.x.toInt(), rod.toY),
          TextStyle(fontSize: 10, color: context.rpText),
        );
      },
    ),
  );
}

/// 通用水平网格线配置
FlGridData buildHorizontalGrid(BuildContext context, double interval) {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: interval,
    getDrawingHorizontalLine: (value) => FlLine(
      color: context.rpBorder.withValues(alpha: 0.3),
      strokeWidth: 0.5,
    ),
  );
}

/// 通用左侧 Y 轴标题配置
AxisTitles buildLeftTitles({
  required BuildContext context,
  required double interval,
  double reservedSize = 28,
  bool showDecimal = true,
}) {
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (value, meta) {
        if (value == 0) return const SizedBox.shrink();
        if (showDecimal) {
          return Text(
            value.toStringAsFixed(
                value == value.roundToDouble() ? 0 : 1),
            style: TextStyle(fontSize: 8, color: context.rpMuted),
          );
        }
        return Text(
          value.toInt().toString(),
          style: TextStyle(fontSize: 8, color: context.rpMuted),
        );
      },
    ),
  );
}

/// 隐藏右侧和顶部标题的常量配置
const hiddenRightTitles =
    AxisTitles(sideTitles: SideTitles(showTitles: false));
const hiddenTopTitles =
    AxisTitles(sideTitles: SideTitles(showTitles: false));
