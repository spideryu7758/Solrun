import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';
import '../providers.dart';
import 'audience_home_notifier.dart';

/// 固定粉丝团区域 — 2 个卡位，可锁定角色组合
class FanTeamSection extends ConsumerWidget {
  final AudienceHomeState data;
  const FanTeamSection({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context)!;
    final fanTeam = data.fanTeam;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区域标题
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            s.audience_fanTeamTitle,
            style: TextStyle(
              fontSize: 12,
              color: context.rpMuted,
              letterSpacing: 2,
            ),
          ),
        ),

        if (fanTeam.isEmpty && data.favorites.isEmpty)
          RpEmptyState(
            icon: Icons.group_add_outlined,
            title: s.audience_fanTeamEmpty,
          )
        else
          Row(
            children: List.generate(2, (i) {
              if (i < fanTeam.length) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == 0 ? 4 : 0,
                      left: i == 1 ? 4 : 0,
                    ),
                    child: _FilledSlot(
                      member: fanTeam[i],
                      onRemove: () => _showActions(context, ref, fanTeam[i]),
                    ),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == 0 ? 4 : 0,
                    left: i == 1 ? 4 : 0,
                  ),
                  child: _EmptySlot(
                    onTap: () => _showRolePicker(context, ref),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, AudienceFavorite member) {
    final s = S.of(context)!;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.rpSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, size: 20),
              title: Text(s.audience_replace, style: TextStyle(color: context.rpText)),
              onTap: () {
                Navigator.pop(context);
                _showRolePicker(context, ref, replaceId: member.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_remove, size: 20, color: Colors.red.withValues(alpha: 0.7)),
              title: Text(s.audience_remove, style: TextStyle(color: Colors.red.withValues(alpha: 0.7))),
              onTap: () {
                Navigator.pop(context);
                ref.read(audienceHomeProvider.notifier).removeFanTeam(member.id);
                RpSnackBar.show(context, s.audience_fanRemoved);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRolePicker(BuildContext context, WidgetRef ref, {int? replaceId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.rpSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RolePickerSheet(
        data: data,
        replaceId: replaceId,
      ),
    );
  }
}

/// 已填充的粉丝团卡位
class _FilledSlot extends StatelessWidget {
  final AudienceFavorite member;
  final VoidCallback onRemove;
  const _FilledSlot({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final role = AudienceRole.fromName(member.audienceRole);
    final personality = Personality.fromName(member.personality);

    return RpTapScale(
      onTap: onRemove,
      child: RpCard(
        tier: RpCardTier.tier2,
        child: Column(
          children: [
            Text(role.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              role.localizedName(s),
              style: TextStyle(fontSize: 12, color: context.rpText, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              personality.localizedName(s),
              style: TextStyle(fontSize: 10, color: context.rpMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 空粉丝团卡位
class _EmptySlot extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptySlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RpTapScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.rpBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(Icons.add, size: 24, color: context.rpMuted.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

/// 角色选择器底部弹窗
class _RolePickerSheet extends ConsumerStatefulWidget {
  final AudienceHomeState data;
  final int? replaceId;
  const _RolePickerSheet({required this.data, this.replaceId});

  @override
  ConsumerState<_RolePickerSheet> createState() => _RolePickerSheetState();
}

class _RolePickerSheetState extends ConsumerState<_RolePickerSheet> {
  AudienceRole? _selectedRole;
  Personality? _selectedPersonality;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final unlockedRoles = AudienceRole.values
        .where((r) => widget.data.isRoleUnlocked(r))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽把手
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              s.audience_selectRole,
              style: TextStyle(fontSize: 16, color: context.rpText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 角色列表
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unlockedRoles.map((role) {
                final selected = _selectedRole == role;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedRole = role;
                    _selectedPersonality = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.rpAccent.withValues(alpha: 0.15)
                          : context.rpCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? context.rpAccent : context.rpBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          role.localizedName(s),
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? context.rpAccent : context.rpText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedRole != null) ...[
              const SizedBox(height: 16),
              Text(
                s.audience_selectPersonality,
                style: TextStyle(fontSize: 14, color: context.rpText, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Personality.values.map((p) {
                  final selected = _selectedPersonality == p;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPersonality = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.rpAccent2.withValues(alpha: 0.15)
                            : context.rpCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? context.rpAccent2 : context.rpBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            p.localizedName(s),
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? context.rpAccent2 : context.rpText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedRole != null && _selectedPersonality != null)
                    ? () async {
                        final notifier = ref.read(audienceHomeProvider.notifier);
                        if (widget.replaceId != null) {
                          final replaced = await notifier.replaceFanTeam(
                            widget.replaceId!,
                            _selectedRole!,
                            _selectedPersonality!,
                          );
                          if (!context.mounted || !replaced) return;
                        } else {
                          final inserted = await notifier.addFanTeam(
                            _selectedRole!,
                            _selectedPersonality!,
                          );
                          if (!context.mounted || !inserted) return;
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        RpSnackBar.show(
                          context,
                          widget.replaceId != null
                              ? s.audience_fanReplaced
                              : s.audience_fanAdded,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.rpAccent,
                  foregroundColor: const Color(0xFF0A0A0F),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: context.rpAccent.withValues(alpha: 0.3),
                ),
                child: Text(s.audience_confirmAdd, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
