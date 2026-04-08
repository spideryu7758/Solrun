import 'package:drift/drift.dart';

import '../database.dart';

part 'audience_unlock_dao.g.dart';

@DriftAccessor(tables: [AudienceUnlocks])
class AudienceUnlockDao extends DatabaseAccessor<AppDatabase>
    with _$AudienceUnlockDaoMixin {
  AudienceUnlockDao(super.db);

  /// 插入一条解锁记录（幂等，重复插入不报错）
  Future<int> insertUnlock(AudienceUnlocksCompanion unlock) {
    return into(audienceUnlocks).insert(
      unlock,
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// 查询某角色是否已解锁
  Future<bool> isUnlocked(String audienceRole) async {
    final result = await (select(audienceUnlocks)
          ..where((t) => t.audienceRole.equals(audienceRole)))
        .getSingleOrNull();
    return result != null;
  }

  /// 获取全部已解锁角色的 role 列表
  Future<List<String>> getUnlockedRoles() async {
    final rows = await (select(audienceUnlocks)
          ..orderBy([(t) => OrderingTerm.asc(t.unlockedAt)]))
        .get();
    return rows.map((r) => r.audienceRole).toList();
  }

  /// 获取全部解锁记录
  Future<List<AudienceUnlock>> getAll() {
    return (select(audienceUnlocks)
          ..orderBy([(t) => OrderingTerm.asc(t.unlockedAt)]))
        .get();
  }

  /// 标记已看解锁动画
  Future<void> markSeen(String audienceRole) async {
    await (update(audienceUnlocks)..where((t) => t.audienceRole.equals(audienceRole)))
        .write(const AudienceUnlocksCompanion(hasSeenAnimation: Value(true)));
  }

  /// 获取未播放动画的解锁记录
  Future<List<AudienceUnlock>> getUnseen() {
    return (select(audienceUnlocks)
          ..where((t) => t.hasSeenAnimation.equals(false)))
        .get();
  }
}
