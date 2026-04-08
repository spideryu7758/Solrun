import 'package:drift/drift.dart';

import '../database.dart';
import '../run_session_status.dart';

part 'run_session_dao.g.dart';

@DriftAccessor(tables: [RunSessions])
class RunSessionDao extends DatabaseAccessor<AppDatabase> with _$RunSessionDaoMixin {
  RunSessionDao(super.db);

  /// 插入跑步记录，返回自增 ID
  Future<int> insertSession(RunSessionsCompanion session) {
    return into(runSessions).insert(session);
  }

  /// 获取所有跑步记录（按开始时间倒序）
  Future<List<RunSession>> getAllSessions() {
    return (select(runSessions)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).get();
  }

  /// 按 ID 获取单条记录
  Future<RunSession?> getSessionById(int id) {
    return (select(runSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 获取本周的跑步记录
  Future<List<RunSession>> getSessionsThisWeek() {
    final now = DateTime.now();
    // 本周一 00:00
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final mondayMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return (select(runSessions)
          ..where((t) => t.startTime.isBiggerOrEqualValue(mondayMidnight))
          ..where((t) => t.status.equals(RunSessionStatus.completed))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  /// 更新跑步记录（endRun 时更新 status、距离、时长等）
  Future<bool> updateSession(RunSessionsCompanion session) {
    return update(runSessions).replace(session);
  }

  /// 删除跑步记录（级联删除在调用方处理）
  Future<int> deleteSession(int id) {
    return (delete(runSessions)..where((t) => t.id.equals(id))).go();
  }

  /// 获取指定日期之后的跑步记录
  Future<List<RunSession>> getSessionsAfter(DateTime after) {
    return (select(runSessions)
          ..where((t) => t.startTime.isBiggerOrEqualValue(after))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  /// 监听所有记录（响��式）
  Stream<List<RunSession>> watchAllSessions() {
    return (select(runSessions)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).watch();
  }

  /// 获取已完成跑步总次数
  Future<int> getTotalCount() async {
    final countExpr = runSessions.id.count();
    final query = selectOnly(runSessions)
      ..addColumns([countExpr])
      ..where(runSessions.status.equals(RunSessionStatus.completed));
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// 已完成记录中最大距离（米）
  Future<double> getMaxDistance() async {
    final maxExpr = runSessions.distanceMeters.max();
    final query = selectOnly(runSessions)
      ..addColumns([maxExpr])
      ..where(runSessions.status.equals(RunSessionStatus.completed));
    final result = await query.getSingle();
    return result.read(maxExpr) ?? 0.0;
  }

  /// 已完成记录中指定最低距离以上的最佳配速（等效配速，秒/公里）
  /// 返回 null 表示无符合条件的记录
  Future<int?> getBestPace({required double minDistance}) async {
    // 等效配速 = durationSeconds * 1000 / distanceMeters
    // SQL 层无法直接 min() 表达式，查询符合距离的记录在 Dart 端取最小值
    final rows = await (select(runSessions)
          ..where((t) => t.status.equals(RunSessionStatus.completed))
          ..where((t) => t.distanceMeters.isBiggerOrEqualValue(minDistance)))
        .get();
    if (rows.isEmpty) return null;
    int? best;
    for (final r in rows) {
      final pace = (r.durationSeconds * 1000 / r.distanceMeters).round();
      if (best == null || pace < best) best = pace;
    }
    return best;
  }

  /// 获取最近 N 条已完成记录（按开始时间倒序）
  Future<List<RunSession>> getRecentCompleted({int limit = 50}) {
    return (select(runSessions)
          ..where((t) => t.status.equals(RunSessionStatus.completed))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .get();
  }
}
