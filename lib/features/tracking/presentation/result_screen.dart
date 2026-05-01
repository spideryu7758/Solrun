import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../shared/utils/polyline_simplifier.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../../../shared/widgets/rp_skeleton.dart';
import '../../../shared/widgets/run_map.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../ai_summary/presentation/summary_screen.dart';
import '../../audience/domain/audience_roles.dart';
import '../../audience/presentation/interview_role_picker.dart';
import '../../audience/presentation/shouts_review_section.dart';
import '../../audience/providers.dart';

/// 跑步完成页
class ResultScreen extends ConsumerWidget {
  final int sessionId;
  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(_resultSessionProvider(sessionId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // 返回键 → 跳转历史页（数据已保存，不应回到 tracking）
          context.go('/history');
        }
      },
      child: Scaffold(
        backgroundColor: context.rpBg,
        body: sessionAsync.when(
        loading: () => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const RpCardSkeleton(height: 120),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: RpCardSkeleton(height: 60)),
                const SizedBox(width: 8),
                const Expanded(child: RpCardSkeleton(height: 60)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Expanded(child: RpCardSkeleton(height: 60)),
                const SizedBox(width: 8),
                const Expanded(child: RpCardSkeleton(height: 60)),
              ]),
            ]),
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (session) {
          if (session == null) return Center(child: Text(S.of(context)!.result_notFound));
          return _buildContent(context, ref, session);
        },
      ),
    ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, RunSession session) {
    final distKm = (session.distanceMeters / 1000).toStringAsFixed(2);
    final durMin = session.durationSeconds ~/ 60;
    final durSec = session.durationSeconds % 60;
    final durStr = '$durMin:${durSec.toString().padLeft(2, '0')}';
    final avgPaceMin = session.avgPaceSecPerKm ~/ 60;
    final avgPaceSec = session.avgPaceSecPerKm % 60;
    final bestPaceMin = session.bestPaceSecPerKm ~/ 60;
    final bestPaceSec = session.bestPaceSecPerKm % 60;

    final achievementsAsync = ref.watch(_achievementsProvider(sessionId));
    final routeAsync = ref.watch(_resultRouteProvider(sessionId));

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部英雄区
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.rpAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                border: Border(bottom: BorderSide(color: context.rpBorder)),
              ),
              child: Column(
                children: [
                  RpFadeSlideIn(
                    delay: Duration.zero,
                    child: Text(S.of(context)!.result_title, style: TextStyle(
                      fontSize: 11, color: context.rpAccent, letterSpacing: 3,
                    )),
                  ),
                  const SizedBox(height: 6),
                  RpFadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(distKm, style: TextStyle(
                          fontFamily: 'BebasNeue', fontSize: 64, color: context.rpText,
                        )),
                        const SizedBox(width: 4),
                        Text('km', style: TextStyle(
                          fontFamily: 'BebasNeue', fontSize: 22, color: context.rpMuted,
                        )),
                      ],
                    ),
                  ),
                  RpFadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Text(durStr, style: TextStyle(
                      fontFamily: 'JetBrainsMono', fontSize: 20, color: context.rpMuted,
                    )),
                  ),
                ],
              ),
            ),

            // 四格数据网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statCell(context, S.of(context)!.result_avgPace, '$avgPaceMin\'${avgPaceSec.toString().padLeft(2, '0')}"', context.rpAccent),
                  _statCell(context, S.of(context)!.result_calories, '${session.caloriesKcal}', context.rpAccent2),
                  _statCell(context, S.of(context)!.result_bestPace, '$bestPaceMin\'${bestPaceSec.toString().padLeft(2, '0')}"', context.rpText),
                  _statCell(context, S.of(context)!.result_elevation, '${session.elevationGainMeters.toStringAsFixed(0)} m', context.rpText),
                ],
              ),
            ),

            // 轨迹地图（点击展开全屏）
            routeAsync.when(
              loading: () => const SizedBox(height: 160),
              error: (e, s) => const SizedBox(height: 160),
              data: (points) {
                if (points.isEmpty) return const SizedBox(height: 160);
                final latLngs = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
                final speeds = points.map((p) => p.speed).toList();
                final simplified = PolylineSimplifier.simplifyWithSpeed(latLngs, speeds, zoom: 14);
                final fitZoom = RunMap.fitZoom(latLngs);
                final centerLat = latLngs.map((p) => p.latitude).reduce((a, b) => a + b) / latLngs.length;
                final centerLng = latLngs.map((p) => p.longitude).reduce((a, b) => a + b) / latLngs.length;
                final simplifiedPoints = simplified.map((s) => s.point).toList();
                final simplifiedSpeeds = simplified.map((s) => s.speed).toList();
                return GestureDetector(
                  onTap: () => _showFullScreenMap(
                    context,
                    center: LatLng(centerLat, centerLng),
                    points: simplifiedPoints,
                    speeds: simplifiedSpeeds,
                    zoom: fitZoom,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          RunMap(
                            center: LatLng(centerLat, centerLng),
                            polylinePoints: simplifiedPoints,
                            speeds: simplifiedSpeeds,
                            zoom: fitZoom,
                            interactive: false,
                            showStartEndMarkers: true,
                          ),
                          // 展开提示
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.fullscreen, size: 14, color: Colors.white70),
                                  const SizedBox(width: 2),
                                  Text(S.of(context)!.result_tapToExpand, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 成就徽章
            achievementsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
              data: (achievements) => Column(
                children: achievements.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.rpAccent.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: RpCard(
                      tier: RpCardTier.tier3,
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: const TextStyle(fontSize: 12)),
                                Text(a.description, style: TextStyle(fontSize: 10, color: context.rpMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 8),
            ShoutsReviewSection(sessionId: sessionId),

            // 赛后采访入口（需要 AI 配置 + 有观众喊话）
            if (ref.watch(aiAvailableProvider))
              Builder(builder: (context) {
                final shoutsVal = ref.watch(sessionShoutsProvider(sessionId)).valueOrNull;
                final unlockedRolesVal =
                    ref.watch(unlockedAudienceRolesProvider).valueOrNull;
                final unlockedRoles = unlockedRolesVal?.toList() ?? const <AudienceRole>[];
                if (shoutsVal == null ||
                    shoutsVal.isEmpty ||
                    unlockedRoles.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RpTapScale(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showInterviewPicker(context, sessionId, unlockedRoles),
                        icon: Text(
                          unlockedRoles.first.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        label: Text(
                          S.of(context)!.audience_interviewTitle,
                          style: TextStyle(fontSize: 13, color: context.rpText),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.rpAccent2.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // AI 总结按钮
            if (ref.watch(aiAvailableProvider))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: RpTapScale(
                    child: OutlinedButton.icon(
                      onPressed: () => SummarySheet.showRunSummary(context, ref, sessionId),
                      icon: Icon(Icons.auto_awesome, size: 16, color: context.rpAccent),
                      label: Text(S.of(context)!.result_aiAnalysis, style: TextStyle(
                        fontSize: 13, color: context.rpText,
                      )),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.rpAccent.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),

            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: RpTapScale(
                      child: ElevatedButton(
                        // 先跳到首页（重置导航栈），再 push 详情页（可返回）
                        onPressed: () {
                          context.go('/history');
                          Future.microtask(() => context.push('/history/$sessionId'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SolrunColors.accent,
                          foregroundColor: const Color(0xFF0A0A0F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(S.of(context)!.result_save, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RpTapScale(
                      child: OutlinedButton(
                        onPressed: () async {
                          final s = ref.read(_resultSessionProvider(sessionId)).valueOrNull;
                          final pts = ref.read(_resultRouteProvider(sessionId)).valueOrNull ?? [];
                          if (s == null) return;
                          await ShareCardHelper.share(context, session: s, points: pts);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.rpText,
                          side: BorderSide(color: context.rpBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(S.of(context)!.result_share, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 弹出角色选择器 → 跳转赛后采访页面
  static void _showInterviewPicker(
    BuildContext context,
    int sessionId,
    List<AudienceRole> unlockedRoles,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => InterviewRolePicker(
        sessionId: sessionId,
        unlockedRoles: unlockedRoles,
      ),
    );
  }

  static void _showFullScreenMap(
    BuildContext context, {
    required LatLng center,
    required List<LatLng> points,
    required List<double> speeds,
    required double zoom,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
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
              // 全屏地图
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: RunMap(
                    center: center,
                    polylinePoints: points,
                    speeds: speeds,
                    zoom: zoom,
                    interactive: true,
                    showStartEndMarkers: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCell(BuildContext context, String label, String value, Color valueColor) {
    // 在 Wrap 中使用 LayoutBuilder 感知宽度，每行两个卡片
    return Builder(
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final cellWidth = (screenWidth - 32 - 8) / 2; // 32=水平 padding, 8=spacing
        return SizedBox(
          width: cellWidth,
          child: RpCard(
            tier: RpCardTier.tier2,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 18,
                  fontWeight: FontWeight.w600, color: valueColor,
                )),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(
                  fontSize: 10, color: context.rpMuted, letterSpacing: 1.5,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

final _resultSessionProvider = StreamProvider.family<RunSession?, int>((ref, id) {
  return ref.read(runSessionDaoProvider).watchSessionById(id);
});

final _resultRouteProvider = FutureProvider.family<List<RoutePoint>, int>((ref, id) {
  return ref.read(routePointDaoProvider).getPointsBySession(id);
});

final _achievementsProvider = FutureProvider.family<List<Achievement>, int>((ref, id) {
  return ref.read(achievementDaoProvider).getBySession(id);
});
