import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../data/database.dart';
import '../../../../l10n/app_localizations.dart';
import 'stats_chart_utils.dart';

/// 年度月跑量柱状图
class YearMonthlyChart extends StatelessWidget {
  const YearMonthlyChart({
    super.key,
    required this.sessions,
    required this.now,
    required this.selectedChartYear,
  });

  final List<RunSession> sessions;
  final DateTime now;
  final int selectedChartYear;

  @override
  Widget build(BuildContext context) {
    // 计算选定年份每月跑量
    final monthlyKm = List.filled(12, 0.0);
    for (final s in sessions) {
      if (s.startTime.year == selectedChartYear) {
        monthlyKm[s.startTime.month - 1] += s.distanceMeters / 1000;
      }
    }

    final maxVal = monthlyKm.reduce((a, b) => a > b ? a : b);
    final ceilMax = maxVal > 0 ? maxVal * 1.2 : 50.0;
    final isCurrentYear = selectedChartYear == now.year;

    final yInterval = calcYInterval(ceilMax, [
      (30, 10),
      (100, 20),
      (300, 50),
    ]);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: ceilMax,
          barTouchData: buildBarTouchData(
            context: context,
            formatTooltip: (index, value) => S.of(context)!
                .stats_tooltipMonth(index + 1, value.toStringAsFixed(1)),
          ),
          titlesData: FlTitlesData(
            leftTitles: buildLeftTitles(
              context: context,
              interval: yInterval,
              reservedSize: 32,
              showDecimal: false,
            ),
            rightTitles: hiddenRightTitles,
            topTitles: hiddenTopTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final m = value.toInt() + 1;
                  return Text('$m',
                      style: TextStyle(
                          fontSize: 9, color: context.rpMuted));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: buildHorizontalGrid(context, yInterval),
          barGroups: List.generate(12, (i) {
            final hasData = monthlyKm[i] > 0;
            final isCurrentMonth = isCurrentYear && i == now.month - 1;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: hasData ? monthlyKm[i] : 0,
                color: isCurrentMonth
                    ? context.rpAccent2
                    : hasData
                        ? context.rpAccent
                        : Colors.transparent,
                width:
                    (MediaQuery.of(context).size.width - 92) / 12 - 2,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3)),
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
    );
  }
}
