import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'stats_chart_utils.dart';

/// 当月每日里程柱状图
class MonthBarChart extends StatelessWidget {
  const MonthBarChart({
    super.key,
    required this.dailyKm,
    required this.now,
    required this.selectedYear,
    required this.selectedMonth,
  });

  final List<double> dailyKm;
  final DateTime now;
  final int selectedYear;
  final int selectedMonth;

  @override
  Widget build(BuildContext context) {
    final maxVal = dailyKm.isNotEmpty
        ? dailyKm.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final isCurrentMonth =
        selectedYear == now.year && selectedMonth == now.month;
    final totalDays = dailyKm.length;

    // 纵坐标：根据最大值计算合适的刻度
    final ceilMax = maxVal > 0 ? maxVal * 1.2 : 5.0;
    final yInterval = calcYInterval(ceilMax, [
      (3, 1),
      (10, 2),
      (30, 5),
    ]);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: ceilMax,
          barTouchData: buildBarTouchData(
            context: context,
            formatTooltip: (index, value) => S.of(context)!
                .stats_tooltipDay(index + 1, value.toStringAsFixed(1)),
          ),
          titlesData: FlTitlesData(
            leftTitles: buildLeftTitles(
              context: context,
              interval: yInterval,
            ),
            rightTitles: hiddenRightTitles,
            topTitles: hiddenTopTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt() + 1;
                  // 显示 1, 5, 10, 15, 20, 25
                  // 末日：仅当天数 <= 30 时显示（31 天不显示末日避免挤在一起）
                  final showLastDay =
                      totalDays <= 30 && day == totalDays;
                  if (day == 1 || day % 5 == 0 || showLastDay) {
                    return Text('$day',
                        style: TextStyle(
                            fontSize: 8,
                            color: context.rpMuted));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: buildHorizontalGrid(context, yInterval),
          barGroups: List.generate(totalDays, (i) {
            final hasData = dailyKm[i] > 0;
            final isToday = isCurrentMonth && i == now.day - 1;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: hasData ? dailyKm[i] : 0,
                color: isToday
                    ? context.rpAccent2
                    : hasData
                        ? context.rpAccent
                        : Colors.transparent,
                width: (MediaQuery.of(context).size.width - 76) /
                        totalDays -
                    1,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal > 0 ? maxVal * 1.3 : 5,
                  color: context.rpBorder.withValues(alpha: 0.2),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}
