import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/rp_skeleton.dart';
import '../providers.dart';
import 'audience_home_notifier.dart';
import 'fan_team_section.dart';
import 'quote_wall_section.dart';
import 'role_gallery_section.dart';

/// 观众席主页 — 替换原 AI 聊天 Tab
class AudienceHomeScreen extends ConsumerWidget {
  const AudienceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(audienceHomeProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncData.when(
          loading: () => _buildSkeleton(),
          error: (e, _) => Center(child: Text('$e', style: TextStyle(color: context.rpText))),
          data: (data) => _buildContent(context, ref, data),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 标题骨架
          RpSkeleton(width: 80, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          const RpCardSkeleton(height: 70),
          const SizedBox(height: 8),
          const RpCardSkeleton(height: 70),
          const SizedBox(height: 20),
          RpSkeleton(width: 80, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: RpCardSkeleton(height: 90)),
              SizedBox(width: 8),
              Expanded(child: RpCardSkeleton(height: 90)),
            ],
          ),
          const SizedBox(height: 20),
          RpSkeleton(width: 80, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: RpCardSkeleton(height: 100)),
              SizedBox(width: 8),
              Expanded(child: RpCardSkeleton(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AudienceHomeState data) {
    return RefreshIndicator(
      color: context.rpAccent,
      backgroundColor: context.rpSurface,
      onRefresh: () => ref.read(audienceHomeProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 页面标题
            Text(
              S.of(context)!.nav_audience,
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 28,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),

            // 金句墙
            QuoteWallSection(data: data),

            // 粉丝团
            FanTeamSection(data: data),

            // 角色图鉴
            RoleGallerySection(data: data),

            // 底部间距
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
