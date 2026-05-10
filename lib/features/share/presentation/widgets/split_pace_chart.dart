import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../data/database.dart';
import '../../domain/share_card_data.dart';

/// 分公里配速柱状图（静态，用于分享卡片截图）
class SplitPaceChart extends StatelessWidget {
  final List<SplitPace> splits;
  final double height;
  final bool dataEntertainment;

  const SplitPaceChart({
    super.key,
    required this.splits,
    this.height = 70,
    this.dataEntertainment = false,
  });

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) return const SizedBox.shrink();

    // 配速转换为分钟数（越低越快）
    final paces = splits
        .map(
          (s) =>
              (dataEntertainment
                  ? ShareCardData.entertainmentPaceDisplaySeconds(
                      s.paceSecPerKm,
                    )
                  : s.paceSecPerKm) /
              60.0,
        )
        .toList();
    var minPace = paces.reduce((a, b) => a < b ? a : b);
    var maxPace = paces.reduce((a, b) => a > b ? a : b);
    // 保护：所有配速相同时避免 Y 轴范围为零导致图表崩溃
    if (maxPace <= minPace) maxPace = minPace + 1;
    final padding = (maxPace - minPace) * 0.2;
    final chartMin = (minPace - padding).clamp(0.0, double.infinity);
    final chartMax = maxPace + padding;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          minY: chartMin,
          // 禁用交互（截图用）
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 16,
                getTitlesWidget: (value, meta) {
                  final km = value.toInt() + 1;
                  // 每 N 个显示一次，避免拥挤
                  final interval = splits.length > 15
                      ? 5
                      : (splits.length > 8 ? 2 : 1);
                  if (km == 1 || km % interval == 0 || km == splits.length) {
                    return Text(
                      '$km',
                      style: const TextStyle(
                        fontSize: 8,
                        color: SolrunColors.darkMuted,
                        decoration: TextDecoration.none,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(splits.length, (i) {
            // 配速归一化着色：快=绿，慢=红
            final t = maxPace > minPace
                ? 1 -
                      (paces[i] - minPace) /
                          (maxPace - minPace) // 反转：低配速=快=1
                : 0.5;
            final hue = t * 120; // 0=红(慢) → 120=绿(快)
            final color = HSLColor.fromAHSL(1.0, hue, 0.85, 0.55).toColor();

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: paces[i],
                  fromY: chartMin,
                  color: color,
                  width: _barWidth(splits.length),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 5) return 16;
    if (count <= 10) return 10;
    if (count <= 20) return 6;
    return 4;
  }
}
