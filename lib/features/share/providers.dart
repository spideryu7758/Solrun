import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/services/geocoding_service.dart';
import '../../shared/services/weather_service.dart';
import 'domain/share_card_config.dart';
import 'domain/share_card_data.dart';
import 'presentation/share_card_notifier.dart';

/// 分享卡片配置状态
final shareCardConfigProvider =
    NotifierProvider<ShareCardNotifier, ShareCardConfig>(ShareCardNotifier.new);

/// 分享卡片数据（按 sessionId 加载，跑后补全 DEM/天气时自动刷新）
final shareCardDataProvider = StreamProvider.family<ShareCardData, int>((
  ref,
  sessionId,
) async* {
  final sessionDao = ref.read(runSessionDaoProvider);
  final routePointDao = ref.read(routePointDaoProvider);
  final splitPaceDao = ref.read(splitPaceDaoProvider);
  final prefs = await SharedPreferences.getInstance();

  final points = await routePointDao.getPointsBySession(sessionId);
  final splits = await splitPaceDao.getSplitsBySession(sessionId);
  await for (final session in sessionDao.watchSessionById(sessionId)) {
    if (session == null) throw Exception('Session not found: $sessionId');

    final nickname = prefs.getString('nickname') ?? 'Runner';
    final avatarPath = prefs.getString('avatar_path');

    // 历史记录可能没有 city/weather（v4 迁移前的数据），实时补充
    String? city = session.city;
    String? weather = session.weather;
    if ((city == null || weather == null) && points.isNotEmpty) {
      final locale = prefs.getString('locale') ?? 'zh';
      final lang = locale.startsWith('en') ? 'en' : 'zh';
      final firstPt = points.first;
      final results2 = await Future.wait([
        if (city == null)
          GeocodingService.getCity(
            firstPt.latitude,
            firstPt.longitude,
            lang: lang,
          )
        else
          Future.value(city),
        if (weather == null)
          WeatherService.fetch(firstPt.latitude, firstPt.longitude)
        else
          Future.value(null),
      ]);
      city ??= results2[0] as String?;
      if (weather == null &&
          results2.length > 1 &&
          results2.last is WeatherResult) {
        final w = results2.last as WeatherResult;
        final temp = w.temperature != null ? '${w.temperature!.round()}°C' : '';
        final desc = w.weatherDescFor(lang);
        weather = temp.isNotEmpty ? '$desc $temp' : desc;
      }
    }

    yield ShareCardData.build(
      session: session,
      points: points,
      splits: splits,
      nickname: nickname,
      avatarPath: avatarPath,
      cityOverride: city,
      weatherOverride: weather,
    );
  }
});

/// 按 sessionId 加载该场次的观众喊话列表
final sessionShoutsProvider = FutureProvider.family<List<AudienceShout>, int>((
  ref,
  sessionId,
) async {
  final shoutDao = ref.read(audienceShoutDaoProvider);
  return shoutDao.getBySession(sessionId);
});
