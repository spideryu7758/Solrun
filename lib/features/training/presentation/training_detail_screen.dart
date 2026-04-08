import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';

/// 训练计划详情页
class TrainingDetailScreen extends ConsumerWidget {
  final int planId;
  const TrainingDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(_planProvider(planId));
    final daysAsync = ref.watch(_daysProvider(planId));

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context)!.trainingDetail_title)),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plan) {
          if (plan == null) return Center(child: Text(S.of(context)!.trainingDetail_notFound));
          return _buildContent(context, plan, daysAsync);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrainingPlan plan, AsyncValue<List<TrainingDay>> daysAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.name, style: const TextStyle(
            fontFamily: 'BebasNeue', fontSize: 32, letterSpacing: 2,
          )),
          const SizedBox(height: 4),
          Text(plan.description, style: TextStyle(
            fontSize: 14, color: context.rpMuted,
          )),
          const SizedBox(height: 4),
          Text(S.of(context)!.trainingDetail_weeksPlan(plan.totalWeeks), style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 12, color: context.rpAccent2,
          )),
          const SizedBox(height: 24),

          // 按周分组的训练日
          daysAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (days) => _buildWeeks(context, days, plan.totalWeeks),
          ),
          const SizedBox(height: 24),

          // 开始训练按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolrunColors.accent,
                foregroundColor: const Color(0xFF0A0A0F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(S.of(context)!.trainingDetail_startTraining, style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeks(BuildContext context, List<TrainingDay> days, int totalWeeks) {
    return Column(
      children: List.generate(totalWeeks, (w) {
        final weekDays = days.where((d) => d.weekIndex == w + 1).toList();
        return _buildWeekCard(context, w + 1, weekDays);
      }),
    );
  }

  Widget _buildWeekCard(BuildContext context, int week, List<TrainingDay> days) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.rpCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rpBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context)!.trainingDetail_week(week), style: TextStyle(
            fontSize: 10, color: context.rpMuted, letterSpacing: 2,
          )),
          const SizedBox(height: 8),
          ...days.map((d) => _buildDayRow(context, d)),
          if (days.isEmpty)
            Text(S.of(context)!.trainingDetail_restWeek, style: TextStyle(color: context.rpMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, TrainingDay day) {
    final dayName = day.dayIndex >= 1 && day.dayIndex <= 7
        ? S.of(context)!.trainingDetail_dayName(day.dayIndex.toString())
        : '?';

    final typeLabels = {
      'easy_run': S.of(context)!.trainingDetail_typeEasyRun,
      'tempo': S.of(context)!.trainingDetail_typeTempo,
      'interval': S.of(context)!.trainingDetail_typeInterval,
      'rest': S.of(context)!.trainingDetail_typeRest,
    };
    final typeColors = {
      'easy_run': context.rpAccent,
      'tempo': context.rpAccent2,
      'interval': context.rpDanger,
      'rest': context.rpMuted,
    };

    String detail = '';
    if (day.targetDistanceMeters != null) {
      detail = '${(day.targetDistanceMeters! / 1000).toStringAsFixed(1)} km';
    }
    if (day.targetPaceSecPerKm != null) {
      final min = day.targetPaceSecPerKm! ~/ 60;
      final sec = day.targetPaceSecPerKm! % 60;
      detail += detail.isEmpty ? '' : ' · ';
      detail += '${S.of(context)!.trainingDetail_target} $min\'${sec.toString().padLeft(2, '0')}"';
    }
    if (day.type == 'interval' && day.intervals != null) {
      detail = S.of(context)!.trainingDetail_intervalTraining;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(dayName, style: TextStyle(
            fontSize: 12, color: context.rpMuted,
          ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (typeColors[day.type] ?? context.rpMuted).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabels[day.type] ?? day.type,
              style: TextStyle(fontSize: 10, color: typeColors[day.type], fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(detail, style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 12, color: context.rpText,
          ))),
        ],
      ),
    );
  }
}

final _planProvider = FutureProvider.family<TrainingPlan?, int>((ref, id) {
  return ref.read(trainingDaoProvider).getPlanById(id);
});

final _daysProvider = FutureProvider.family<List<TrainingDay>, int>((ref, planId) {
  return ref.read(trainingDaoProvider).getDaysByPlan(planId);
});
