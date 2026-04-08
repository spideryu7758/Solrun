import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';

/// 训练计划列表（从首页的训练 Tab 进入）
class TrainingListScreen extends ConsumerWidget {
  const TrainingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(_plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.training_title, style: TextStyle(
          fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 3,
          color: Theme.of(context).textTheme.displaySmall?.color,
        )),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(child: Text(S.of(context)!.training_emptyTitle));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _buildPlanCard(context, plans[i]),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, TrainingPlan plan) {
    final typeIcons = {
      '5km': '🏃',
      '10km': '🏅',
      '间歇': '⚡',
    };
    final icon = typeIcons.entries
        .firstWhere((e) => plan.name.contains(e.key), orElse: () => const MapEntry('', '📋'))
        .value;

    return GestureDetector(
      onTap: () => context.push('/training/${plan.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.rpCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.rpBorder),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(plan.description, style: TextStyle(
                    fontSize: 12, color: context.rpMuted,
                  )),
                  const SizedBox(height: 4),
                  Text(S.of(context)!.training_weeks(plan.totalWeeks), style: TextStyle(
                    fontFamily: 'JetBrainsMono', fontSize: 11,
                    color: context.rpAccent2,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.rpMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

final _plansProvider = FutureProvider<List<TrainingPlan>>((ref) {
  return ref.read(trainingDaoProvider).getAllPlans();
});
