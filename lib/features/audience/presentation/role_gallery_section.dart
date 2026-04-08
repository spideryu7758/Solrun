import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../domain/audience_roles.dart';
import 'audience_home_notifier.dart';
import 'role_detail_sheet.dart';

/// 角色图鉴区域 — 7 个角色卡片网格
class RoleGallerySection extends ConsumerWidget {
  final AudienceHomeState data;
  const RoleGallerySection({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区域标题
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            s.audience_roleGalleryTitle,
            style: TextStyle(
              fontSize: 12,
              color: context.rpMuted,
              letterSpacing: 2,
            ),
          ),
        ),

        // 2 列网格
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: AudienceRole.values.map((role) {
            final unlocked = data.isRoleUnlocked(role);
            final count = data.roleCounts[role.name] ?? 0;

            if (unlocked) {
              return _UnlockedCard(
                role: role,
                count: count,
                data: data,
              );
            } else {
              return _LockedCard(
                role: role,
                totalRunCount: data.totalRunCount,
              );
            }
          }).toList(),
        ),
      ],
    );
  }
}

/// 已解锁角色卡片
class _UnlockedCard extends StatelessWidget {
  final AudienceRole role;
  final int count;
  final AudienceHomeState data;
  const _UnlockedCard({
    required this.role,
    required this.count,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return RpTapScale(
      onTap: () {
        HapticFeedback.selectionClick();
        RoleDetailSheet.show(context, role: role, data: data);
      },
      child: RpCard(
        tier: RpCardTier.tier2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(role.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              role.localizedName(s),
              style: TextStyle(
                fontSize: 13,
                color: context.rpText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              s.audience_shoutCount(count),
              style: TextStyle(fontSize: 10, color: context.rpMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// 未解锁角色卡片
class _LockedCard extends StatelessWidget {
  final AudienceRole role;
  final int totalRunCount;
  const _LockedCard({required this.role, required this.totalRunCount});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final remaining = (role.unlockThreshold - totalRunCount).clamp(0, role.unlockThreshold);
    final progress = totalRunCount / role.unlockThreshold;

    return Container(
      decoration: BoxDecoration(
        color: context.rpCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rpBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 28, color: context.rpMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 6),
          Text(
            role.localizedName(s),
            style: TextStyle(
              fontSize: 13,
              color: context.rpMuted.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            s.audience_runsToUnlock(remaining),
            style: TextStyle(fontSize: 10, color: context.rpMuted.withValues(alpha: 0.4)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: context.rpBorder,
              valueColor: AlwaysStoppedAnimation(context.rpMuted.withValues(alpha: 0.3)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
