import 'dart:convert';
import 'dart:io';

/// 实时天气服务（Open-Meteo，免费无需 API Key）
///
/// 根据 GPS 经纬度获取当前温度、天气状况、风速。
/// 跑步开始时调用一次，缓存本次跑步期间复用。
class WeatherService {
  WeatherService._();

  static WeatherResult? _cached;
  static DateTime? _cachedAt;

  /// 获取当前天气（缓存 10 分钟）
  static Future<WeatherResult?> fetch(double lat, double lon) async {
    // 10 分钟内复用缓存
    if (_cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!).inMinutes < 10) {
      return _cached;
    }

    HttpClient? client;
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m'
        '&timezone=auto',
      );

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(url);
      final response = await request.close().timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode != 200) {
        return null;
      }

      // 响应体读取也加超时保护，防止慢速连接无限挂起
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 5));

      final json = jsonDecode(body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      final result = WeatherResult(
        temperature: (current['temperature_2m'] as num?)?.toDouble(),
        weatherCode: current['weather_code'] as int? ?? 0,
        windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble(),
        windDirection: current['wind_direction_10m'] as int?,
      );

      _cached = result;
      _cachedAt = DateTime.now();
      return result;
    } catch (_) {
      // 天气获取失败（含超时）不影响跑步，静默返回 null
      return null;
    } finally {
      client?.close();
    }
  }

  /// 清除缓存（新跑步时调用）
  static void clearCache() {
    _cached = null;
    _cachedAt = null;
  }
}

/// 天气结果
class WeatherResult {
  final double? temperature;
  final int weatherCode;
  final double? windSpeedKmh;
  final int? windDirection;

  const WeatherResult({
    this.temperature,
    required this.weatherCode,
    this.windSpeedKmh,
    this.windDirection,
  });

  /// WMO 天气代码 → 中文描述
  String get weatherDescZh {
    if (weatherCode <= 1) return '晴';
    if (weatherCode <= 2) return '多云';
    if (weatherCode <= 3) return '阴';
    if (weatherCode <= 48) return '雾';
    if (weatherCode <= 55) return '毛毛雨';
    if (weatherCode <= 57) return '冻毛毛雨';
    if (weatherCode <= 61) return '小雨';
    if (weatherCode <= 63) return '中雨';
    if (weatherCode <= 65) return '大雨';
    if (weatherCode <= 67) return '冻雨';
    if (weatherCode <= 71) return '小雪';
    if (weatherCode <= 73) return '中雪';
    if (weatherCode <= 75) return '大雪';
    if (weatherCode <= 77) return '雪粒';
    if (weatherCode <= 80) return '小阵雨';
    if (weatherCode <= 81) return '阵雨';
    if (weatherCode <= 82) return '暴阵雨';
    if (weatherCode <= 86) return '阵雪';
    if (weatherCode <= 95) return '雷暴';
    return '雷暴冰雹';
  }

  /// WMO 天气代码 → 英文描述
  String get weatherDescEn {
    if (weatherCode <= 1) return 'Clear';
    if (weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode <= 3) return 'Overcast';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 55) return 'Drizzle';
    if (weatherCode <= 57) return 'Freezing drizzle';
    if (weatherCode <= 61) return 'Light rain';
    if (weatherCode <= 63) return 'Rain';
    if (weatherCode <= 65) return 'Heavy rain';
    if (weatherCode <= 67) return 'Freezing rain';
    if (weatherCode <= 71) return 'Light snow';
    if (weatherCode <= 73) return 'Snow';
    if (weatherCode <= 75) return 'Heavy snow';
    if (weatherCode <= 77) return 'Snow grains';
    if (weatherCode <= 80) return 'Light showers';
    if (weatherCode <= 81) return 'Showers';
    if (weatherCode <= 82) return 'Heavy showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode <= 95) return 'Thunderstorm';
    return 'Thunderstorm with hail';
  }

  /// 根据语言获取天气描述
  String weatherDescFor(String lang) =>
      lang == 'en' ? weatherDescEn : weatherDescZh;

  /// 是否有降水（雨/雪/冰雹）
  bool get isRainy => weatherCode >= 51 && weatherCode <= 67 ||
      weatherCode >= 80 && weatherCode <= 82;

  bool get isSnowy => weatherCode >= 71 && weatherCode <= 77 ||
      weatherCode >= 85 && weatherCode <= 86;

  bool get isThunderstorm => weatherCode >= 95;

  /// 风力等级描述
  String get windDescZh {
    if (windSpeedKmh == null) return '';
    final ws = windSpeedKmh!;
    if (ws < 2) return '无风';
    if (ws < 12) return '微风';
    if (ws < 30) return '和风';
    if (ws < 50) return '强风';
    if (ws < 75) return '大风';
    return '暴风';
  }

  String get windDescEn {
    if (windSpeedKmh == null) return '';
    final ws = windSpeedKmh!;
    if (ws < 2) return 'calm';
    if (ws < 12) return 'light breeze';
    if (ws < 30) return 'moderate wind';
    if (ws < 50) return 'strong wind';
    if (ws < 75) return 'gale';
    return 'storm';
  }

  /// 格式化为 prompt 片段
  String formatForPrompt(String lang) {
    final isEn = lang == 'en';
    final parts = <String>[];

    parts.add(isEn
        ? 'Weather: ${weatherDescEn}'
        : '天气：$weatherDescZh');

    if (temperature != null) {
      parts.add(isEn
          ? 'Temperature: ${temperature!.round()}°C'
          : '气温：${temperature!.round()}°C');
    }

    final wd = isEn ? windDescEn : windDescZh;
    if (wd.isNotEmpty && windSpeedKmh != null) {
      parts.add(isEn
          ? 'Wind: $wd (${windSpeedKmh!.round()} km/h)'
          : '风力：$wd（${windSpeedKmh!.round()} km/h）');
    }

    return parts.join(isEn ? ', ' : '，');
  }
}
