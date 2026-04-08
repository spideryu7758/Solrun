import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../data/database.dart';
import '../../../../l10n/app_localizations.dart';
import 'stats_chart_utils.dart';

/// 历年跑量柱状图（可左右滑动）
class AllYearsChart extends StatelessWidget {
  const AllYearsChart({
    super.key,
    required this.sessions,
  });

  final List<RunSession> sessions;

  @override
  Widget build(BuildContext context) {
    // 按年聚合跑量
    final yearMap = <int, double>{};
    for (final s in sessions) {
      yearMap[s.startTime.year] =
          (yearMap[s.startTime.year] ?? 0) + s.distanceMeters / 1000;
    }
    if (yearMap.isEmpty) return const SizedBox.shrink();

    final sortedYears = yearMap.keys.toList()..sort();
    final yearKm = sortedYears.map((y) => yearMap[y]!).toList();
    final maxVal = yearKm.reduce((a, b) => a > b ? a : b);
    final ceilMax = maxVal > 0 ? maxVal * 1.2 : 500.0;
    final now = DateTime.now();

    final yInterval = calcYInterval(ceilMax, [
      (200, 50),
      (500, 100),
      (1500, 300),
    ]);

    // 柱宽根据年份数量自适应，但有最小宽度保证可滑动
    final chartWidth = (sortedYears.length * 60.0).clamp(
      MediaQuery.of(context).size.width - 60,
      double.infinity,
    );

    return SizedBox(
      height: 160,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // 默认显示最右侧（最新年份）
        child: SizedBox(
          width: chartWidth,
          child: BarChart(
            BarChartData(
              maxY: ceilMax,
              barTouchData: buildBarTouchData(
                context: context,
                formatTooltip: (index, value) => S.of(context)!
                    .stats_tooltipYear(
                        sortedYears[index], value.toStringAsFixed(0)),
              ),
              titlesData: FlTitlesData(
                leftTitles: buildLeftTitles(
                  context: context,
                  interval: yInterval,
                  reservedSize: 36,
                  showDecimal: false,
                ),
                rightTitles: hiddenRightTitles,
                topTitles: hiddenTopTitles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sortedYears.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        '${sortedYears[idx]}',
                        style: TextStyle(
                            fontSize: 9, color: context.rpMuted),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: buildHorizontalGrid(context, yInterval),
              barGroups: List.generate(sortedYears.length, (i) {
                final isCurrentYear = sortedYears[i] == now.year;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: yearKm[i],
                    color: isCurrentYear
                        ? context.rpAccent2
                        : context.rpAccent,
                    width: 32,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: ceilMax,
                      color: context.rpBorder.withValues(alpha: 0.15),
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
