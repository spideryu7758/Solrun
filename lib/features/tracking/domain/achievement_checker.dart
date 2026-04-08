import '../../../data/database.dart';
import '../../../data/daos/achievement_dao.dart';
import '../../../data/daos/run_session_dao.dart';

/// 成就检测结果
class AchievementResult {
  final String type;
  final String title;
  final String description;

  const AchievementResult({
    required this.type,
    required this.title,
    required this.description,
  });
}

/// 成就检测器 — 跑步结束时调用，返回本次触发的成就列表
class AchievementChecker {
  final RunSessionDao _sessionDao;
  final AchievementDao _achievementDao;

  AchievementChecker(this._sessionDao, this._achievementDao);

  /// 检测本次跑步触发的成就
  ///
  /// 使用聚合查询替代全表加载，避免 N+1 性能问题。
  Future<List<AchievementResult>> check({
    required int sessionId,
    required double distanceMeters,
    required int durationSeconds,
    required int avgPaceSecPerKm,
  }) async {
    final results = <AchievementResult>[];
    final existingAchievements = await _achievementDao.getAll();
    final existingTypes = existingAchievements.map((a) => a.type).toSet();

    // 1. 首次跑步 — 用聚合计数替代全表加载
    final completedCount = await _sessionDao.getTotalCount();
    if (completedCount <= 1 && !existingTypes.contains('first_run')) {
      results.add(const AchievementResult(
        type: 'first_run',
        title: '首次跑步',
        description: '完成了你的第一次跑步记录！',
      ));
    }

    // 2. 最远距离 — 用 MAX 聚合查询替代内存过滤
    final prevMaxDistance = await _sessionDao.getMaxDistance();
    // prevMaxDistance 包含本次记录（已入库），如果本次是唯一最大值则触发成就
    // 当历史最大值等于本次距离时，说明本次刷新了纪录（或无历史记录）
    if (completedCount > 1 && distanceMeters >= prevMaxDistance) {
      // 精确判断：如果历史最大恰好等于本次，可能是本次自身，需要判断之前是否有同样距离
      // 简化逻辑：本次距离 >= 历史最大（含自身），且已完成 > 1 条，即为新纪录
      results.add(AchievementResult(
        type: 'longest_distance',
        title: '新纪录！最远距离',
        description:
            '${(distanceMeters / 1000).toStringAsFixed(2)} km — 超越了你的历史最远记录',
      ));
    }

    // 3. 最快 5km — 用聚合查询替代内存过滤
    if (distanceMeters >= 5000) {
      final fiveKmPace = (durationSeconds * 5000 / distanceMeters).round();
      final prevBest5k =
          await _sessionDao.getBestPace(minDistance: 5000);
      if (prevBest5k == null || fiveKmPace <= prevBest5k) {
        final min = fiveKmPace ~/ 60;
        final sec = fiveKmPace % 60;
        results.add(AchievementResult(
          type: 'fastest_5km',
          title: '新纪录！最快 5km',
          description:
              '$min\'${sec.toString().padLeft(2, '0')}" — 你的最快 5 公里配速',
        ));
      }
    }

    // 4. 最快 10km — 用聚合查询替代内存过滤
    if (distanceMeters >= 10000) {
      final tenKmPace = (durationSeconds * 10000 / distanceMeters).round();
      final prevBest10k =
          await _sessionDao.getBestPace(minDistance: 10000);
      if (prevBest10k == null || tenKmPace <= prevBest10k) {
        final min = tenKmPace ~/ 60;
        final sec = tenKmPace % 60;
        results.add(AchievementResult(
          type: 'fastest_10km',
          title: '新纪录！最快 10km',
          description:
              '$min\'${sec.toString().padLeft(2, '0')}" — 你的最快 10 公里配速',
        ));
      }
    }

    // 5. 周跑量突破（20/50/100 km）
    final thisWeek = await _sessionDao.getSessionsThisWeek();
    final weekTotal =
        thisWeek.fold<double>(0, (sum, s) => sum + s.distanceMeters) / 1000;
    for (final threshold in [20, 50, 100]) {
      final type = 'weekly_${threshold}km';
      if (weekTotal >= threshold && !existingTypes.contains(type)) {
        results.add(AchievementResult(
          type: type,
          title: '周跑量突破 $threshold km',
          description: '本周累计跑步 ${weekTotal.toStringAsFixed(1)} km！',
        ));
      }
    }

    // 写入数据库
    for (final r in results) {
      await _achievementDao.insertAchievement(AchievementsCompanion.insert(
        sessionId: sessionId,
        type: r.type,
        title: r.title,
        description: r.description,
        achievedAt: DateTime.now(),
      ));
    }

    return results;
  }
}
