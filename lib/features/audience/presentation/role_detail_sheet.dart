import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/database.dart';
import '../../../shared/widgets/rp_components.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';
import '../providers.dart';
import 'audience_home_notifier.dart';

/// 角色详情底部弹窗
class RoleDetailSheet extends ConsumerWidget {
  final AudienceRole role;
  final AudienceHomeState data;

  const RoleDetailSheet({super.key, required this.role, required this.data});

  static void show(BuildContext context, {required AudienceRole role, required AudienceHomeState data}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoleDetailSheet(role: role, data: data),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context)!;
    final count = data.roleCounts[role.name] ?? 0;
    final shoutsAsync = ref.watch(roleRecentShoutsProvider(role.name));

    // 检查是否已在粉丝团中
    final fanEntry = data.fanTeam.where((f) => f.audienceRole == role.name).firstOrNull;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: context.rpSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽把手
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 角色头部
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Text(role.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  role.localizedName(s),
                  style: TextStyle(
                    fontSize: 18,
                    color: context.rpText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _roleDescKey(role, s),
                  style: TextStyle(fontSize: 12, color: context.rpMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  s.audience_shoutCount(count),
                  style: TextStyle(fontSize: 11, color: context.rpAccent),
                ),
              ],
            ),
          ),

          // 分割线
          Divider(height: 1, color: context.rpBorder),

          // 历史喊话列表
          Flexible(
            child: shoutsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    s.audience_noShoutsYet,
                    style: TextStyle(fontSize: 13, color: context.rpMuted),
                  ),
                ),
              ),
              data: (shouts) {
                if (shouts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        s.audience_noShoutsYet,
                        style: TextStyle(fontSize: 13, color: context.rpMuted),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: shouts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ShoutCard(
                    shout: shouts[i],
                    onFavoriteChanged: () =>
                        ref.invalidate(roleRecentShoutsProvider(role.name)),
                  ),
                );
              },
            ),
          ),

          // 粉丝团操作按钮
          if (data.isRoleUnlocked(role))
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: fanEntry != null
                      ? OutlinedButton.icon(
                          onPressed: () {
                            ref.read(audienceHomeProvider.notifier).removeFanTeam(fanEntry.id);
                            Navigator.pop(context);
                            RpSnackBar.show(context, s.audience_fanRemoved);
                          },
                          icon: Icon(Icons.person_remove, size: 16, color: Colors.red.withValues(alpha: 0.7)),
                          label: Text(
                            s.audience_removeFromFanTeam,
                            style: TextStyle(color: Colors.red.withValues(alpha: 0.7), fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showPersonalityPicker(context, ref);
                          },
                          icon: Icon(Icons.group_add, size: 16, color: const Color(0xFF0A0A0F)),
                          label: Text(
                            s.audience_joinFanTeam,
                            style: const TextStyle(color: Color(0xFF0A0A0F), fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.rpAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPersonalityPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.rpSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PersonalityPicker(
        role: role,
        isFull: data.fanTeam.length >= 2,
      ),
    );
  }

  String _roleDescKey(AudienceRole r, S s) {
    switch (r) {
      case AudienceRole.screamingFan: return s.audience_roleDesc_screamingFan;
      case AudienceRole.dataNerd: return s.audience_roleDesc_dataNerd;
      case AudienceRole.familyCrew: return s.audience_roleDesc_familyCrew;
      case AudienceRole.zenViewer: return s.audience_roleDesc_zenViewer;
      case AudienceRole.gambler: return s.audience_roleDesc_gambler;
      case AudienceRole.nitpicker: return s.audience_roleDesc_nitpicker;
      case AudienceRole.rivalFan: return s.audience_roleDesc_rivalFan;
    }
  }
}

/// 人格选择弹窗（加入粉丝团时使用）
class _PersonalityPicker extends ConsumerStatefulWidget {
  final AudienceRole role;
  final bool isFull;
  const _PersonalityPicker({required this.role, required this.isFull});

  @override
  ConsumerState<_PersonalityPicker> createState() => _PersonalityPickerState();
}

class _PersonalityPickerState extends ConsumerState<_PersonalityPicker> {
  Personality? _selected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              s.audience_selectPersonality,
              style: TextStyle(fontSize: 16, color: context.rpText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Personality.values.map((p) {
                final selected = _selected == p;
                return GestureDetector(
                  onTap: () => setState(() => _selected = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Text(p.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          p.localizedName(s),
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? context.rpAccent2 : context.rpText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected != null
                    ? () async {
                        final inserted = await ref
                            .read(audienceHomeProvider.notifier)
                            .addFanTeam(widget.role, _selected!);
                        if (!context.mounted || !inserted) return;
                        Navigator.pop(context);
                        RpSnackBar.show(context, s.audience_fanAdded);
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

/// 历史语录卡片（点击复制，❤️切换收藏）
class _ShoutCard extends StatefulWidget {
  final AudienceShout shout;
  final VoidCallback onFavoriteChanged;

  const _ShoutCard({required this.shout, required this.onFavoriteChanged});

  @override
  State<_ShoutCard> createState() => _ShoutCardState();
}

class _ShoutCardState extends State<_ShoutCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.shout.isFavorite;
  }

  @override
  void didUpdateWidget(_ShoutCard old) {
    super.didUpdateWidget(old);
    if (old.shout.id != widget.shout.id) {
      _isFavorite = widget.shout.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final personality = Personality.fromName(widget.shout.personality);

    String scene = '';
    try {
      final ctx = jsonDecode(widget.shout.triggerContext) as Map<String, dynamic>;
      final type = ctx['triggerType'] as String?;
      final km = ctx['currentKm'];
      if (type == 'start') {
        scene = s.audience_sceneStart;
      } else if (type == 'split_km' && km != null) {
        scene = s.audience_sceneSplitKm(km);
      } else if (type == 'finish') {
        scene = s.audience_sceneFinish;
      } else if (type == 'pace_alert') {
        scene = s.audience_scenePaceAlert;
      }
    } catch (_) {}

    final dateStr = '${widget.shout.createdAt.month}/${widget.shout.createdAt.day}';

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.shout.content));
        RpSnackBar.show(context, s.audience_quoteCopied);
      },
      child: RpCard(
        tier: RpCardTier.tier1,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(personality.emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  personality.localizedName(s),
                  style: TextStyle(fontSize: 10, color: context.rpMuted),
                ),
                const Spacer(),
                // 收藏按钮
                GestureDetector(
                  onTap: _toggleFavorite,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: _isFavorite ? Colors.redAccent : context.rpMuted.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy, size: 12, color: context.rpMuted.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  '$dateStr${scene.isNotEmpty ? ' · $scene' : ''}',
                  style: TextStyle(fontSize: 9, color: context.rpMuted.withValues(alpha: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.shout.content,
              style: TextStyle(fontSize: 13, color: context.rpText, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final dao = ProviderScope.containerOf(context)
        .read(audienceShoutDaoProvider);
    final newVal = !_isFavorite;
    await dao.setFavorite(widget.shout.id, newVal);
    if (!mounted) return;
    setState(() => _isFavorite = newVal);
    widget.onFavoriteChanged();
    final s = S.of(context)!;
    RpSnackBar.show(
      context,
      newVal ? s.audience_favoriteAdded : s.audience_favoriteRemoved,
    );
  }
}
