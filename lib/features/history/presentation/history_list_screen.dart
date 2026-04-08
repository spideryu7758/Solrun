import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../data/run_session_status.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../../../shared/widgets/rp_skeleton.dart';
import '../../../l10n/app_localizations.dart';

/// 月分组数据
class _MonthGroup {
  final String key; // "2026-3"
  final String label; // "三月"
  final String year; // "2026"
  final List<RunSession> sessions;

  _MonthGroup({required this.key, required this.label, required this.year, required this.sessions});

  double get totalKm => sessions.fold<double>(0, (sum, s) => sum + s.distanceMeters) / 1000;
  int get totalCount => sessions.length;
  double get totalHours => sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds) / 3600;
}

/// 历史记录列表（按月分组，可折叠）
class HistoryListScreen extends ConsumerStatefulWidget {
  const HistoryListScreen({super.key});

  @override
  ConsumerState<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends ConsumerState<HistoryListScreen> {
  // 记录哪些月份被展开了（默认当前月展开）
  final Set<String> _expandedMonths = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(_sessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.history_title, style: TextStyle(
          fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 3,
          color: Theme.of(context).textTheme.displaySmall?.color,
        )),
      ),
      body: sessionsAsync.when(
        loading: () => ListView(
          children: List.generate(5, (_) => const RpSessionTileSkeleton()),
        ),
        error: (e, _) => Center(child: Text('${S.of(context)!.history_loadError}: $e')),
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmptyState(context);
          final groups = _groupByMonth(sessions);
          // 首次加载时展开第一个月
          if (!_initialized && groups.isNotEmpty) {
            _expandedMonths.add(groups.first.key);
            _initialized = true;
          }
          return _buildGroupedList(context, groups);
        },
      ),
    );
  }

  List<_MonthGroup> _groupByMonth(List<RunSession> sessions) {
    final map = <String, List<RunSession>>{};
    for (final s in sessions) {
      final key = '${s.startTime.year}-${s.startTime.month}';
      map.putIfAbsent(key, () => []).add(s);
    }
    const monthNames = ['', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    final groups = map.entries.map((e) {
      final parts = e.key.split('-');
      return _MonthGroup(
        key: e.key,
        label: monthNames[int.parse(parts[1])],
        year: parts[0],
        sessions: e.value,
      );
    }).toList();
    // 按年月倒序排序（最新月份在前），避免 HashMap 迭代顺序不确定
    groups.sort((a, b) {
      final pa = a.key.split('-');
      final pb = b.key.split('-');
      final cmpYear = int.parse(pb[0]).compareTo(int.parse(pa[0]));
      if (cmpYear != 0) return cmpYear;
      return int.parse(pb[1]).compareTo(int.parse(pa[1]));
    });
    return groups;
  }

  Widget _buildEmptyState(BuildContext context) {
    return RpEmptyState(
      icon: Icons.directions_run,
      title: S.of(context)!.history_emptyTitle,
      subtitle: S.of(context)!.history_emptySubtitle,
      actionLabel: S.of(context)!.history_startRunning,
      onAction: () => context.push('/tracking'),
    );
  }

  Widget _buildGroupedList(BuildContext context, List<_MonthGroup> groups) {
    return RefreshIndicator(
      color: context.rpAccent,
      onRefresh: () async => ref.invalidate(_sessionsProvider),
      child: ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isExpanded = _expandedMonths.contains(group.key);
        return Column(
          children: [
            // 月份头部（点击折叠/展开）
            _buildMonthHeader(context, group, isExpanded),
            // 展开时显示记录列表
            if (isExpanded)
              ...group.sessions.map((s) => _buildSessionTile(context, s)),
            // 底部分隔线
            Divider(color: context.rpBorder, height: 1),
          ],
        );
      },
    ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, _MonthGroup group, bool isExpanded) {
    return InkWell(
      onTap: () => setState(() {
        if (isExpanded) {
          _expandedMonths.remove(group.key);
        } else {
          _expandedMonths.add(group.key);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 左侧：月份 + 年份
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3, height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: context.rpAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(S.of(context)!.history_monthName(group.label), style: TextStyle(
                        fontFamily: 'BebasNeue', fontSize: 22,
                        color: context.rpAccent,
                      )),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: context.rpAccent, size: 20,
                      ),
                    ],
                  ),
                  Text(group.year, style: TextStyle(
                    fontSize: 12, color: context.rpMuted,
                  )),
                ],
              ),
            ),
            // 右侧：汇总数据
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(group.totalKm.toStringAsFixed(2), style: TextStyle(
                      fontFamily: 'JetBrainsMono', fontSize: 18,
                      fontWeight: FontWeight.w600, color: context.rpText,
                    )),
                    const SizedBox(width: 2),
                    Text(S.of(context)!.history_unitKm, style: TextStyle(fontSize: 11, color: context.rpMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  S.of(context)!.history_monthSummary(group.totalCount, group.totalHours.toStringAsFixed(1)),
                  style: TextStyle(fontSize: 11, color: context.rpMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, RunSession session) {
    final isIncomplete = session.status == RunSessionStatus.incomplete;
    final distKm = (session.distanceMeters / 1000).toStringAsFixed(1);
    final durMin = session.durationSeconds ~/ 60;
    final durSec = session.durationSeconds % 60;
    final durStr = S.of(context)!.history_durationFormat(durMin, durSec.toString().padLeft(2, '0'));
    final icon = _getTimeIcon(session.startTime.hour);

    final iconBgColor = _getTimeIconBg(session.startTime.hour);

    return Opacity(
      opacity: isIncomplete ? 0.5 : 1.0,
      child: RpTapScale(
        onTap: () => context.push('/history/${session.id}'),
        onLongPress: () => _showDeleteDialog(context, session),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.rpBorder.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                // 时段图标
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.rpBorder),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
                ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(session.autoName, style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                        )),
                        if (isIncomplete) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: context.rpDanger.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(S.of(context)!.history_incomplete, style: TextStyle(
                              fontSize: 9, color: context.rpDanger,
                            )),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(session.startTime)} · $durStr',
                      style: TextStyle(fontSize: 11, color: context.rpMuted),
                    ),
                  ],
                ),
              ),
              // 距离
              Text(distKm, style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: 20,
                fontWeight: FontWeight.w600, color: context.rpAccent,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, RunSession session) async {
    final confirmed = await RpDialog.confirm(
      context,
      title: S.of(context)!.history_deleteConfirmTitle,
      content: S.of(context)!.history_deleteConfirmContent(session.autoName),
      confirmText: S.of(context)!.history_deleteConfirmButton,
      confirmColor: context.rpDanger,
    );

    if (confirmed == true) {
      final routePointDao = ref.read(routePointDaoProvider);
      final splitPaceDao = ref.read(splitPaceDaoProvider);
      final achievementDao = ref.read(achievementDaoProvider);
      final audienceShoutDao = ref.read(audienceShoutDaoProvider);
      final sessionDao = ref.read(runSessionDaoProvider);
      // 级联删除所有关联数据
      await routePointDao.deleteBySession(session.id);
      await splitPaceDao.deleteBySession(session.id);
      await achievementDao.deleteBySession(session.id);
      await audienceShoutDao.deleteBySession(session.id);
      await sessionDao.deleteSession(session.id);
    }
  }

  /// 根据时段返回图标背景色
  static Color _getTimeIconBg(int hour) {
    if (hour >= 5 && hour < 9) return Colors.orange.withValues(alpha: 0.08);
    if (hour >= 9 && hour < 14) return Colors.amber.withValues(alpha: 0.06);
    if (hour >= 14 && hour < 19) return Colors.blue.withValues(alpha: 0.06);
    return Colors.indigo.withValues(alpha: 0.08);
  }

  static String _getTimeIcon(int hour) {
    if (hour >= 5 && hour < 9) return '🌅';
    if (hour >= 9 && hour < 12) return '☀️';
    if (hour >= 12 && hour < 14) return '🌤️';
    if (hour >= 14 && hour < 17) return '🏃';
    if (hour >= 17 && hour < 19) return '🌆';
    return '🌙';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) return S.of(context)!.history_today;
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) return S.of(context)!.history_yesterday;
    return '${dt.month}/${dt.day}';
  }
}

/// 响应式监听所有跑步记录
final _sessionsProvider = StreamProvider<List<RunSession>>((ref) {
  return ref.read(runSessionDaoProvider).watchAllSessions();
});
