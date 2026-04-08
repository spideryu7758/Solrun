import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'daos/achievement_dao.dart';
import 'daos/audience_favorite_dao.dart';
import 'daos/audience_shout_dao.dart';
import 'daos/audience_unlock_dao.dart';
import 'daos/chat_dao.dart';
import 'daos/route_point_dao.dart';
import 'daos/run_session_dao.dart';
import 'daos/split_pace_dao.dart';
import 'daos/training_dao.dart';

/// 全局数据库实例
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final runSessionDaoProvider = Provider<RunSessionDao>((ref) {
  return RunSessionDao(ref.read(databaseProvider));
});

final routePointDaoProvider = Provider<RoutePointDao>((ref) {
  return RoutePointDao(ref.read(databaseProvider));
});

final splitPaceDaoProvider = Provider<SplitPaceDao>((ref) {
  return SplitPaceDao(ref.read(databaseProvider));
});

final achievementDaoProvider = Provider<AchievementDao>((ref) {
  return AchievementDao(ref.read(databaseProvider));
});

final trainingDaoProvider = Provider<TrainingDao>((ref) {
  return TrainingDao(ref.read(databaseProvider));
});

final chatDaoProvider = Provider<ChatDao>((ref) {
  return ChatDao(ref.read(databaseProvider));
});

// ── 观众系统 DAO Providers ──

final audienceShoutDaoProvider = Provider<AudienceShoutDao>((ref) {
  return AudienceShoutDao(ref.read(databaseProvider));
});

final audienceFavoriteDaoProvider = Provider<AudienceFavoriteDao>((ref) {
  return AudienceFavoriteDao(ref.read(databaseProvider));
});

final audienceUnlockDaoProvider = Provider<AudienceUnlockDao>((ref) {
  return AudienceUnlockDao(ref.read(databaseProvider));
});
