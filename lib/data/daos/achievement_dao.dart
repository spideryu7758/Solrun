import 'package:drift/drift.dart';

import '../database.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<AppDatabase> with _$AchievementDaoMixin {
  AchievementDao(super.db);

  Future<int> insertAchievement(AchievementsCompanion achievement) {
    return into(achievements).insert(achievement);
  }

  /// 按 sessionId 查询成就
  Future<List<Achievement>> getBySession(int sessionId) {
    return (select(achievements)..where((t) => t.sessionId.equals(sessionId))).get();
  }

  /// 查询所有成就（用于去重判断）
  Future<List<Achievement>> getAll() {
    return select(achievements).get();
  }

  /// 按 sessionId 删除
  Future<int> deleteBySession(int sessionId) {
    return (delete(achievements)..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
