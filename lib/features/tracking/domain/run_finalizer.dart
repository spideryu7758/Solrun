import 'package:drift/drift.dart';

import '../../../data/database.dart';
import '../../../data/daos/achievement_dao.dart';
import '../../../data/daos/audience_unlock_dao.dart';
import '../../../data/daos/route_point_dao.dart';
import '../../../data/daos/run_session_dao.dart';
import '../../../shared/services/geocoding_service.dart';
import '../../../shared/services/weather_service.dart';
import '../../audience/domain/unlock_checker.dart';
import 'achievement_checker.dart';

/// 跑步结束收尾结果
class FinalizeResult {
  final String? city;
  final String? weather;

  const FinalizeResult({this.city, this.weather});
}

/// 跑步结束收尾服务
///
/// 负责跑步结束后的附属逻辑：城市识别、天气获取、成就检测、角色解锁。
/// 不持有运动状态，由 TrackingNotifier.endRun() 编排调用。
class RunFinalizer {
  final RunSessionDao _runSessionDao;
  final RoutePointDao _routePointDao;
  final AchievementDao _achievementDao;
  final AudienceUnlockDao _audienceUnlockDao;

  RunFinalizer({
    required RunSessionDao runSessionDao,
    required RoutePointDao routePointDao,
    required AchievementDao achievementDao,
    required AudienceUnlockDao audienceUnlockDao,
  })  : _runSessionDao = runSessionDao,
        _routePointDao = routePointDao,
        _achievementDao = achievementDao,
        _audienceUnlockDao = audienceUnlockDao;

  /// 获取城市和天气信息（用首个轨迹点的坐标）
  Future<FinalizeResult> fetchCityAndWeather({
    required int sessionId,
    required String lang,
  }) async {
    String? city;
    String? weatherStr;

    final point = await _routePointDao.getFirstPoint(sessionId);
    if (point != null) {
      // 并行获取城市和天气
      final results = await Future.wait([
        GeocodingService.getCity(
            point.latitude, point.longitude, lang: lang),
        WeatherService.fetch(point.latitude, point.longitude),
      ]);
      city = results[0] as String?;
      final weather = results[1] as WeatherResult?;
      if (weather != null) {
        final temp = weather.temperature != null
            ? '${weather.temperature!.round()}°C'
            : '';
        final desc = weather.weatherDescFor(lang);
        weatherStr = temp.isNotEmpty ? '$desc $temp' : desc;
      }
    }

    return FinalizeResult(city: city, weather: weatherStr);
  }

  /// 检测成就
  Future<void> checkAchievements({
    required int sessionId,
    required double distanceMeters,
    required int durationSeconds,
    required int avgPaceSecPerKm,
  }) async {
    final checker = AchievementChecker(_runSessionDao, _achievementDao);
    await checker.check(
      sessionId: sessionId,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      avgPaceSecPerKm: avgPaceSecPerKm,
    );
  }

  /// 检测观众角色解锁
  Future<void> checkAudienceUnlocks() async {
    final totalRunCount = await _runSessionDao.getTotalCount();
    final alreadyUnlocked = (await _audienceUnlockDao.getAll())
        .map((row) => row.audienceRole)
        .toSet();
    final newUnlocks = UnlockChecker.check(
      totalRunCount: totalRunCount,
      alreadyUnlockedNames: alreadyUnlocked,
    );
    for (final role in newUnlocks) {
      await _audienceUnlockDao.insertUnlock(
        AudienceUnlocksCompanion.insert(
          audienceRole: role.name,
          unlockedAt: DateTime.now(),
          unlockedAtRunCount: totalRunCount,
          hasSeenAnimation: const Value(false),
        ),
      );
    }
  }
}
