import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/run_session_status.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../../../shared/widgets/rp_skeleton.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../ai_summary/domain/summary_prompt.dart';
import '../../ai_summary/presentation/summary_screen.dart';
import 'widgets/month_bar_chart.dart';
import 'widgets/year_monthly_chart.dart';
import 'widgets/all_years_chart.dart';

/// 统计页面 — 本周/本月汇总 + 月柱状图（可切换月份）+ 个人记录
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedChartYear; // 年度月跑量图的年份

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedChartYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(_allSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.stats_title, style: TextStyle(
          fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 3,
          color: Theme.of(context).textTheme.displaySmall?.color,
        )),
      ),
      body: sessionsAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                const Expanded(child: RpCardSkeleton(height: 100)),
                const SizedBox(width: 8),
                const Expanded(child: RpCardSkeleton(height: 100)),
              ]),
              const SizedBox(height: 16),
              const RpCardSkeleton(height: 180),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (sessions) {
          final completed = sessions
              .where((s) => s.status == RunSessionStatus.completed)
              .toList();
          if (completed.isEmpty) return _buildEmptyState(context);
          return _buildStats(context, completed);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RpEmptyState(
      icon: Icons.bar_chart,
      title: S.of(context)!.stats_emptyTitle,
      actionLabel: S.of(context)!.stats_emptyAction,
      onAction: () => context.push('/tracking'),
    );
  }

  Widget _buildStats(BuildContext context, List<RunSession> sessions) {
    final now = DateTime.now();

    // 本周数据
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final thisWeek = sessions.where((s) => s.startTime.isAfter(monday)).toList();

    // 本月数据
    final thisMonth = sessions.where((s) =>
        s.startTime.year == now.year && s.startTime.month == now.month).toList();

    // 选定月份数据（柱状图用）
    final selectedMonthSessions = sessions.where((s) =>
        s.startTime.year == _selectedYear && s.startTime.month == _selectedMonth).toList();
    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    final dailyKm = List.filled(daysInMonth, 0.0);
    for (final s in selectedMonthSessions) {
      dailyKm[s.startTime.day - 1] += s.distanceMeters / 1000;
    }

    // 个人记录（找到对应 session 以支持跳转）
    final maxDistSession = sessions.reduce((a, b) => a.distanceMeters > b.distanceMeters ? a : b);
    final maxDurationSession = sessions.reduce((a, b) => a.durationSeconds > b.durationSeconds ? a : b);
    final paceFiltered = sessions.where((s) => s.avgPaceSecPerKm > 0).toList();
    final bestPaceSession = paceFiltered.isNotEmpty
        ? paceFiltered.reduce((a, b) => a.avgPaceSecPerKm < b.avgPaceSecPerKm ? a : b)
        : null;
    final fiveKmList = sessions.where((s) => s.distanceMeters >= 5000).toList();
    RunSession? best5kmSession;
    int? best5km;
    if (fiveKmList.isNotEmpty) {
      best5kmSession = fiveKmList.reduce((a, b) {
        final pa = (a.durationSeconds * 5000 / a.distanceMeters).round();
        final pb = (b.durationSeconds * 5000 / b.distanceMeters).round();
        return pa < pb ? a : b;
      });
      best5km = (best5kmSession.durationSeconds * 5000 / best5kmSession.distanceMeters).round();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 本周 + 本月汇总卡片（并排）
          Row(
            children: [
              Expanded(child: _buildSummaryCard(context, S.of(context)!.stats_thisWeek, thisWeek)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard(context, S.of(context)!.stats_thisMonth, thisMonth)),
            ],
          ),
          const SizedBox(height: 16),

          // 月柱状图（含年月选择器）
          RpCard(
            tier: RpCardTier.tier1,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(context),
                const SizedBox(height: 12),
                MonthBarChart(
                  dailyKm: dailyKm,
                  now: now,
                  selectedYear: _selectedYear,
                  selectedMonth: _selectedMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 年度月跑量柱状图（可切换年份）
          RpCard(
            tier: RpCardTier.tier1,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYearSelector(context, sessions),
                const SizedBox(height: 12),
                YearMonthlyChart(
                  sessions: sessions,
                  now: now,
                  selectedChartYear: _selectedChartYear,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 历年跑量柱状图（可左右滑动）
          RpCard(
            tier: RpCardTier.tier1,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context)!.stats_allYearsVolume, style: TextStyle(
                  fontSize: 12, color: context.rpMuted, letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 12),
                AllYearsChart(sessions: sessions),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // AI 总结入口
          if (ref.watch(aiAvailableProvider)) ...[
            Text(S.of(context)!.stats_aiSummaryLabel, style: TextStyle(
              fontSize: 10, color: context.rpMuted, letterSpacing: 2,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildAiSummaryButton(context, S.of(context)!.stats_aiWeeklySummary, SummaryType.weekly),
                const SizedBox(width: 8),
                _buildAiSummaryButton(context, S.of(context)!.stats_aiMonthlySummary, SummaryType.monthly),
                const SizedBox(width: 8),
                _buildAiSummaryButton(context, S.of(context)!.stats_aiYearlySummary, SummaryType.yearly),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // 个人记录
          Text(S.of(context)!.stats_personalRecords, style: TextStyle(
            fontSize: 10, color: context.rpMuted, letterSpacing: 2,
          )),
          const SizedBox(height: 8),
          _buildRecordCard(context, S.of(context)!.stats_longestDistance,
              '${(maxDistSession.distanceMeters / 1000).toStringAsFixed(2)} km',
              sessionId: maxDistSession.id),
          _buildRecordCard(context, S.of(context)!.stats_longestDuration,
              '${maxDurationSession.durationSeconds ~/ 3600 > 0 ? "${maxDurationSession.durationSeconds ~/ 3600}h " : ""}${(maxDurationSession.durationSeconds % 3600) ~/ 60}min',
              sessionId: maxDurationSession.id),
          if (bestPaceSession != null)
            _buildRecordCard(context, S.of(context)!.stats_fastestPace,
                '${bestPaceSession.avgPaceSecPerKm ~/ 60}\'${(bestPaceSession.avgPaceSecPerKm % 60).toString().padLeft(2, '0')}"/km',
                sessionId: bestPaceSession.id),
          if (best5km != null && best5kmSession != null)
            _buildRecordCard(context, S.of(context)!.stats_fastest5km,
                '${best5km ~/ 60}\'${(best5km % 60).toString().padLeft(2, '0')}"/km',
                sessionId: best5kmSession.id),
        ],
      ),
    );
  }

  /// 汇总卡片（本周/本月通用）
  Widget _buildSummaryCard(BuildContext context, String title, List<RunSession> sessions) {
    final distKm = sessions.fold<double>(0, (sum, s) => sum + s.distanceMeters) / 1000;
    final count = sessions.length;
    final avgPace = sessions.isNotEmpty
        ? (sessions.fold<int>(0, (sum, s) => sum + s.avgPaceSecPerKm) / sessions.length).round()
        : 0;
    final pMin = avgPace ~/ 60;
    final pSec = avgPace % 60;

    return RpCard(
      tier: RpCardTier.tier3,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontSize: 10, color: context.rpMuted, letterSpacing: 2,
          )),
          const SizedBox(height: 8),
          Text(distKm.toStringAsFixed(1), style: const TextStyle(
            fontFamily: 'BebasNeue', fontSize: 28,
          )),
          Text(S.of(context)!.stats_unitKm, style: TextStyle(fontSize: 10, color: context.rpMuted)),
          const SizedBox(height: 6),
          Text(S.of(context)!.stats_timesAndPace(count, avgPace > 0 ? "$pMin'${pSec.toString().padLeft(2, '0')}\"" : '--'),
            style: TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 11, color: context.rpMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// 年月选择器
  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左箭头
        GestureDetector(
          onTap: () => setState(() {
            if (_selectedMonth == 1) {
              _selectedYear--;
              _selectedMonth = 12;
            } else {
              _selectedMonth--;
            }
          }),
          child: Icon(Icons.chevron_left, color: context.rpMuted, size: 24),
        ),
        // 年月标签（点击年选年，点击月选月）
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _pickYear(context),
              child: Text(
                S.of(context)!.stats_yearSuffix(_selectedYear),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 14,
                  fontWeight: FontWeight.w600, color: context.rpText,
                  decoration: TextDecoration.underline,
                  decorationColor: context.rpMuted,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _pickMonth(context),
              child: Text(
                S.of(context)!.stats_monthSuffix(_selectedMonth),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 14,
                  fontWeight: FontWeight.w600, color: context.rpText,
                  decoration: TextDecoration.underline,
                  decorationColor: context.rpMuted,
                ),
              ),
            ),
          ],
        ),
        // 右箭头（不超过当前月）
        GestureDetector(
          onTap: () {
            final now = DateTime.now();
            if (_selectedYear > now.year ||
                (_selectedYear == now.year && _selectedMonth >= now.month)) {
              return; // 不能超过当前月
            }
            setState(() {
              if (_selectedMonth == 12) {
                _selectedYear++;
                _selectedMonth = 1;
              } else {
                _selectedMonth++;
              }
            });
          },
          child: Icon(Icons.chevron_right, color: context.rpMuted, size: 24),
        ),
      ],
    );
  }

  Future<void> _pickYear(BuildContext context) async {
    final now = DateTime.now();
    final years = List.generate(now.year - 1980 + 1, (i) => 1980 + i);
    // 滚动到当前选中年份的位置（每项约 48px）
    final selectedIndex = years.indexOf(_selectedYear);
    final controller = ScrollController(
      initialScrollOffset: (selectedIndex > 3 ? selectedIndex - 3 : 0) * 48.0,
    );
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: context.rpCard,
        title: Text(S.of(context)!.stats_selectYear, style: TextStyle(color: context.rpText)),
        children: [
          SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              controller: controller,
              itemCount: years.length,
              itemExtent: 48,
              itemBuilder: (_, i) {
                final y = years[i];
                return SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(y),
                  child: Text(
                    S.of(context)!.stats_yearSuffix(y),
                    style: TextStyle(
                      color: y == _selectedYear ? context.rpAccent : context.rpText,
                      fontWeight: y == _selectedYear ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (picked != null) {
      setState(() {
        _selectedYear = picked;
        if (_selectedYear == now.year && _selectedMonth > now.month) {
          _selectedMonth = now.month;
        }
      });
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final maxMonth = _selectedYear == now.year ? now.month : 12;
    final months = List.generate(maxMonth, (i) => i + 1);
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: context.rpCard,
        title: Text(S.of(context)!.stats_selectMonth, style: TextStyle(color: context.rpText)),
        children: months.map((m) => SimpleDialogOption(
          onPressed: () => Navigator.of(ctx).pop(m),
          child: Text(
            S.of(context)!.stats_monthSuffix(m),
            style: TextStyle(
              color: m == _selectedMonth ? context.rpAccent : context.rpText,
              fontWeight: m == _selectedMonth ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        )).toList(),
      ),
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  Widget _buildAiSummaryButton(BuildContext context, String label, SummaryType type) {
    return Expanded(
      child: RpTapScale(
        onTap: () => SummarySheet.showPeriodSummary(context, ref, type),
        child: RpCard(
          tier: RpCardTier.tier2,
          padding: const EdgeInsets.symmetric(vertical: 10),
          borderColor: context.rpAccent.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: context.rpAccent),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                fontSize: 11, color: context.rpText, fontWeight: FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ── 年度月跑量柱状图年份选择器 ──

  Widget _buildYearSelector(BuildContext context, List<RunSession> sessions) {
    final now = DateTime.now();
    // 找出最早和最晚年份
    final years = sessions.map((s) => s.startTime.year).toSet().toList()..sort();
    final minYear = years.isNotEmpty ? years.first : now.year;
    final maxYear = now.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _selectedChartYear > minYear
              ? () => setState(() => _selectedChartYear--)
              : null,
          child: Icon(Icons.chevron_left, size: 24,
            color: _selectedChartYear > minYear ? context.rpMuted : context.rpBorder),
        ),
        Text(
          S.of(context)!.stats_yearMonthlyVolume(_selectedChartYear),
          style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 14,
            fontWeight: FontWeight.w600, color: context.rpText,
          ),
        ),
        GestureDetector(
          onTap: _selectedChartYear < maxYear
              ? () => setState(() => _selectedChartYear++)
              : null,
          child: Icon(Icons.chevron_right, size: 24,
            color: _selectedChartYear < maxYear ? context.rpMuted : context.rpBorder),
        ),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, String label, String value, {int? sessionId}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RpTapScale(
        onTap: sessionId != null ? () => context.push('/history/$sessionId') : null,
        child: RpCard(
          tier: RpCardTier.tier2,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: context.rpMuted)),
              const Spacer(),
              Text(value, style: TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 16,
                fontWeight: FontWeight.w600, color: context.rpAccent,
              )),
              if (sessionId != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 16, color: context.rpMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final _allSessionsProvider = StreamProvider<List<RunSession>>((ref) {
  return ref.read(runSessionDaoProvider).watchAllSessions();
});
