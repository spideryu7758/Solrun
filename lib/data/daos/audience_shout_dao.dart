import 'package:drift/drift.dart';

import '../database.dart';

part 'audience_shout_dao.g.dart';

@DriftAccessor(tables: [AudienceShouts])
class AudienceShoutDao extends DatabaseAccessor<AppDatabase>
    with _$AudienceShoutDaoMixin {
  AudienceShoutDao(super.db);

  /// 插入一条喊话记录，返回自增 ID
  Future<int> insertShout(AudienceShoutsCompanion shout) {
    return into(audienceShouts).insert(shout);
  }

  /// 按跑步记录查询所有喊话（按时间正序）
  Future<List<AudienceShout>> getBySession(int sessionId) {
    return (select(audienceShouts)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// 按跑步记录统计喊话数量
  Future<int> getCountBySession(int sessionId) async {
    final count = audienceShouts.id.count();
    final query = selectOnly(audienceShouts)
      ..addColumns([count])
      ..where(audienceShouts.sessionId.equals(sessionId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 查询收藏的喊话（按时间倒序）
  Future<List<AudienceShout>> getFavorites() {
    return (select(audienceShouts)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(int id, bool currentValue) async {
    await (update(audienceShouts)..where((t) => t.id.equals(id))).write(
      AudienceShoutsCompanion(isFavorite: Value(!currentValue)),
    );
  }

  /// 显式设置收藏状态，避免调用方错误依赖 toggle 语义。
  Future<void> setFavorite(int id, bool isFavorite) async {
    await (update(audienceShouts)..where((t) => t.id.equals(id))).write(
      AudienceShoutsCompanion(isFavorite: Value(isFavorite)),
    );
  }

  /// 按角色统计喊话次数
  Future<Map<String, int>> countByRole() async {
    final count = audienceShouts.id.count();
    final query = selectOnly(audienceShouts)
      ..addColumns([audienceShouts.audienceRole, count])
      ..groupBy([audienceShouts.audienceRole]);
    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(audienceShouts.audienceRole)!: row.read(count) ?? 0,
    };
  }

  /// 按角色查询最近 N 条喊话
  Future<List<AudienceShout>> getRecentByRole(String audienceRole,
      {int limit = 20}) {
    return (select(audienceShouts)
          ..where((t) => t.audienceRole.equals(audienceRole))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// 按 sessionId 删除所有喊话
  Future<int> deleteBySession(int sessionId) {
    return (delete(audienceShouts)..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
