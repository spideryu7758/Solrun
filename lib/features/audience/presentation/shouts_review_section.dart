import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/rp_components.dart';
import '../../audience/domain/audience_roles.dart';
import '../../audience/domain/personalities.dart';
import '../../audience/providers.dart';

/// 赛后喊话回顾区域（嵌入结果页）
class ShoutsReviewSection extends ConsumerWidget {
  final int sessionId;

  const ShoutsReviewSection({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context)!;
    final shoutsAsync = ref.watch(sessionShoutsProvider(sessionId));

    return shoutsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (shouts) {
        if (shouts.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    s.audience_shoutsTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.rpMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...shouts.map((shout) {
                final role = AudienceRole.fromName(shout.audienceRole);
                final personality = Personality.fromName(shout.personality);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RpCard(
                    tier: RpCardTier.tier1,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(role.emoji, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${role.localizedName(s)}\u00B7${personality.localizedName(s)}',
                                    style: TextStyle(fontSize: 10, color: context.rpMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shout.content,
                                style: TextStyle(fontSize: 13, color: context.rpText, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await ref.read(audienceShoutDaoProvider).setFavorite(
                                  shout.id,
                                  !shout.isFavorite,
                                );
                            ref.invalidate(sessionShoutsProvider(sessionId));
                            ref.invalidate(audienceHomeProvider);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              shout.isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: shout.isFavorite
                                  ? Colors.red
                                  : context.rpMuted.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
