import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/rp_components.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/utils/polyline_simplifier.dart';
import '../../../shared/widgets/run_map.dart';
import '../../../shared/widgets/share_card.dart';
import '../../export/csv_exporter.dart';
import '../../export/gpx_exporter.dart';
import 'widgets/trajectory_replay_widget.dart';
import '../../../l10n/app_localizations.dart';

/// 跑步详情页
class HistoryDetailScreen extends ConsumerWidget {
  final int sessionId;
  const HistoryDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(_sessionDetailProvider(sessionId));
    final splitsAsync = ref.watch(_splitsProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.historyDetail_title),
        leading: const BackButton(),
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${S.of(context)!.historyDetail_loadError}: $e')),
        data: (session) {
          if (session == null) {
            return Center(child: Text(S.of(context)!.historyDetail_notFound));
          }
          return _buildContent(context, ref, session, splitsAsync);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, RunSession session, AsyncValue<List<SplitPace>> splitsAsync) {
    final distKm = (session.distanceMeters / 1000).toStringAsFixed(2);
    final routeAsync = ref.watch(_routePointsProvider(sessionId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 地图轨迹（异步加载 + 降采样）
          routeAsync.when(
            loading: () => Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.rpCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.rpCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(S.of(context)!.historyDetail_trajectoryLoadError, style: TextStyle(color: context.rpMuted))),
            ),
            data: (points) {
              if (points.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.rpCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(S.of(context)!.historyDetail_noTrajectory, style: TextStyle(color: context.rpMuted))),
                );
              }
              final latLngs = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
              if (latLngs.isEmpty) {
                // 空轨迹保护：避免 reduce() 在空列表上抛出 StateError
                return RunMap(
                  center: LatLng(39.9, 116.4),
                  polylinePoints: const [],
                  speeds: const [],
                  zoom: 10,
                  height: 200,
                  showStartEndMarkers: false,
                );
              }
              final speeds = points.map((p) => p.speed).toList();
              final simplified = PolylineSimplifier.simplifyWithSpeed(latLngs, speeds, zoom: 15);
              final fitZoom = RunMap.fitZoom(latLngs);
              // 中心点取平均值
              final centerLat = latLngs.map((p) => p.latitude).reduce((a, b) => a + b) / latLngs.length;
              final centerLng = latLngs.map((p) => p.longitude).reduce((a, b) => a + b) / latLngs.length;

              return RunMap(
                center: LatLng(centerLat, centerLng),
                polylinePoints: simplified.map((s) => s.point).toList(),
                speeds: simplified.map((s) => s.speed).toList(),
                zoom: fitZoom,
                height: 200,
                showStartEndMarkers: true,
              );
            },
          ),
          const SizedBox(height: 16),

          // 标题区（点击可编辑）
          GestureDetector(
            onTap: () => _showRenameDialog(context, ref, session),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(session.autoName, style: const TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 2,
                  ), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit_outlined, size: 16, color: context.rpMuted),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatFullDate(session.startTime),
            style: TextStyle(color: context.rpMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // 数据卡片网格
          _buildDataGrid(context, session, distKm),
          const SizedBox(height: 24),

          // 分公里配速
          Text(S.of(context)!.historyDetail_splitPace, style: TextStyle(
            fontSize: 10, color: context.rpMuted, letterSpacing: 2,
          )),
          const SizedBox(height: 8),
          splitsAsync.when(
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('${S.of(context)!.historyDetail_loadError}: $e'),
            data: (splits) => splits.isEmpty
                ? Text(S.of(context)!.historyDetail_distanceTooShort, style: TextStyle(color: context.rpMuted))
                : _buildSplitPaces(context, splits),
          ),
          const SizedBox(height: 24),

          // 轨迹回放按钮
          routeAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (points) {
              if (points.length < 2) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TrajectoryReplayWidget(
                          points: points,
                          session: session,
                        ),
                      ));
                    },
                    icon: Icon(Icons.play_circle_outline, size: 18, color: context.rpAccent),
                    label: Text(S.of(context)!.historyDetail_replay, style: TextStyle(color: context.rpText)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.rpAccent.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              );
            },
          ),

          // 分享按钮
          RpTapScale(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pts = ref.read(_routePointsProvider(sessionId)).valueOrNull ?? [];
                  final sp = ref.read(_splitsProvider(sessionId)).valueOrNull ?? [];
                  await ShareCardHelper.share(context, session: session, points: pts, splits: sp);
                },
                icon: const Icon(Icons.share, size: 16),
                label: Text(S.of(context)!.historyDetail_share),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolrunColors.accent,
                  foregroundColor: const Color(0xFF0A0A0F),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 导出按钮
          Row(
            children: [
              Expanded(
                child: RpTapScale(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportGpx(context, ref, session),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('GPX'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.rpText,
                      side: BorderSide(color: context.rpBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RpTapScale(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportCsv(context, ref, session),
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.rpText,
                      side: BorderSide(color: context.rpBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 删除按钮
          Center(
            child: TextButton.icon(
              onPressed: () => _showDeleteDialog(context, ref, session),
              icon: Icon(Icons.delete_outline, color: context.rpDanger, size: 18),
              label: Text(S.of(context)!.historyDetail_delete, style: TextStyle(color: context.rpDanger)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataGrid(BuildContext context, RunSession session, String distKm) {
    final avgPaceMin = session.avgPaceSecPerKm ~/ 60;
    final avgPaceSec = session.avgPaceSecPerKm % 60;
    final bestPaceMin = session.bestPaceSecPerKm ~/ 60;
    final bestPaceSec = session.bestPaceSecPerKm % 60;
    final durMin = session.durationSeconds ~/ 60;
    final durSec = session.durationSeconds % 60;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _dataCard(context, S.of(context)!.historyDetail_distance, '$distKm km', context.rpAccent),
        _dataCard(context, S.of(context)!.historyDetail_duration, '${durMin.toString().padLeft(2, '0')}:${durSec.toString().padLeft(2, '0')}', context.rpText),
        _dataCard(context, S.of(context)!.historyDetail_pace, '$avgPaceMin\'${avgPaceSec.toString().padLeft(2, '0')}"', context.rpAccent),
        _dataCard(context, S.of(context)!.historyDetail_bestPace, '$bestPaceMin\'${bestPaceSec.toString().padLeft(2, '0')}"', context.rpAccent2),
        _dataCard(context, S.of(context)!.historyDetail_calories, '${session.caloriesKcal} kcal', context.rpAccent2),
        _dataCard(context, S.of(context)!.historyDetail_elevation, '${session.elevationGainMeters.toStringAsFixed(0)} m', context.rpText),
      ],
    );
  }

  Widget _dataCard(BuildContext context, String label, String value, Color valueColor) {
    return SizedBox(
      width: 160,
      child: RpCard(
        tier: RpCardTier.tier2,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              fontSize: 10, color: context.rpMuted, letterSpacing: 1.5,
            )),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitPaces(BuildContext context, List<SplitPace> splits) {
    // 预计算最快/最慢配速，用于 HSL 渐变着色
    final paces = splits.map((s) => s.paceSecPerKm).toList();
    final minPace = paces.reduce((a, b) => a < b ? a : b); // 最快
    final maxPace = paces.reduce((a, b) => a > b ? a : b); // 最慢

    return Column(
      children: splits.map((s) {
        final min = s.paceSecPerKm ~/ 60;
        final sec = s.paceSecPerKm % 60;

        // 配速归一化：0=最慢(红) → 1=最快(绿)
        final t = maxPace > minPace
            ? 1 - (s.paceSecPerKm - minPace) / (maxPace - minPace)
            : 0.5;
        final barColor = HSLColor.fromAHSL(
          1.0, t * 120, 0.85, 0.55,
        ).toColor();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.rpBorder)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('${s.kmIndex} km', style: TextStyle(
                  fontSize: 12, color: context.rpMuted,
                )),
              ),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$min\'${sec.toString().padLeft(2, '0')}"',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _exportGpx(BuildContext context, WidgetRef ref, RunSession session) async {
    try {
      final points = await ref.read(routePointDaoProvider).getPointsBySession(session.id);
      final gpx = GpxExporter.export(session, points);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${session.autoName}.gpx');
      await file.writeAsString(gpx);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (context.mounted) {
        RpSnackBar.show(context, 'GPX ${S.of(context)!.historyDetail_exportFailed}: $e');
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref, RunSession session) async {
    try {
      final splits = await ref.read(splitPaceDaoProvider).getSplitsBySession(session.id);
      final csv = CsvExporter.export(session, splits);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${session.autoName}.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (context.mounted) {
        RpSnackBar.show(context, 'CSV ${S.of(context)!.historyDetail_exportFailed}: $e');
      }
    }
  }

  /// 重命名跑步记录对话框
  Future<void> _showRenameDialog(
    BuildContext context, WidgetRef ref, RunSession session,
  ) async {
    final controller = TextEditingController(text: session.autoName);
    try {
    final s = S.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.rpSurface,
        title: Text(s.historyDetail_rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: ctx.rpText),
          decoration: InputDecoration(
            hintText: session.autoName,
            hintStyle: TextStyle(color: ctx.rpMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.historyDetail_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(s.historyDetail_save),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != session.autoName) {
      final dao = ref.read(runSessionDaoProvider);
      await dao.updateSession(RunSessionsCompanion(
        id: Value(session.id),
        autoName: Value(result),
      ));
      // 刷新详情页数据
      ref.invalidate(_sessionDetailProvider(session.id));
    }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, RunSession session) async {
    final confirmed = await RpDialog.confirm(
      context,
      title: S.of(context)!.history_deleteConfirmTitle,
      content: S.of(context)!.history_deleteConfirmContent(session.autoName),
      confirmText: S.of(context)!.history_deleteConfirmButton,
      confirmColor: context.rpDanger,
    );
    if (confirmed != true) return;

    // 级联删除所有关联数据（外键 cascade 兜底，应用层也显式删除确保兼容旧数据库）
    final routePointDao = ref.read(routePointDaoProvider);
    final splitPaceDao = ref.read(splitPaceDaoProvider);
    final achievementDao = ref.read(achievementDaoProvider);
    final audienceShoutDao = ref.read(audienceShoutDaoProvider);
    final sessionDao = ref.read(runSessionDaoProvider);
    await routePointDao.deleteBySession(session.id);
    await splitPaceDao.deleteBySession(session.id);
    await achievementDao.deleteBySession(session.id);
    await audienceShoutDao.deleteBySession(session.id);
    await sessionDao.deleteSession(session.id);

    if (context.mounted) context.go('/history');
  }

  static String _formatFullDate(DateTime dt) {
    return '${dt.year}/${dt.month}/${dt.day} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// 按 ID 查询单条记录
final _sessionDetailProvider = FutureProvider.family<RunSession?, int>((ref, id) {
  return ref.read(runSessionDaoProvider).getSessionById(id);
});

/// 按 sessionId 查询分公里配速
final _splitsProvider = FutureProvider.family<List<SplitPace>, int>((ref, sessionId) {
  return ref.read(splitPaceDaoProvider).getSplitsBySession(sessionId);
});

/// 按 sessionId 查询轨迹点（异步加载，详情页地图用）
final _routePointsProvider = FutureProvider.family<List<RoutePoint>, int>((ref, sessionId) {
  return ref.read(routePointDaoProvider).getPointsBySession(sessionId);
});
