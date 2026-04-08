import '../../../shared/services/weather_service.dart';

/// 天气/环境检测器
///
/// 时段信息从跑步开始时间推断，天气数据从 WeatherService 实时获取。
class WeatherDetector {
  WeatherDetector._();

  /// 检测跑步环境信息
  ///
  /// [weather] 由 WeatherService.fetch() 获取的实时天气，可为 null（离线/获取失败）
  static WeatherInfo detect(DateTime startTime, {WeatherResult? weather}) {
    final hour = startTime.hour;
    final timeOfDay = _getTimeOfDay(hour);
    final isNight = hour >= 23 || hour < 5;
    final isDawn = hour >= 4 && hour < 6;

    return WeatherInfo(
      timeOfDay: timeOfDay,
      temperature: weather?.temperature?.round(),
      isNight: isNight,
      isDawn: isDawn,
      weatherDesc: weather?.weatherDescZh,
      weatherDescEn: weather?.weatherDescEn,
      windDesc: weather?.windDescZh,
      windDescEn: weather?.windDescEn,
      isRainy: weather?.isRainy ?? false,
      isSnowy: weather?.isSnowy ?? false,
      isThunderstorm: weather?.isThunderstorm ?? false,
      weatherForPrompt: weather?.formatForPrompt('zh'),
      weatherForPromptEn: weather?.formatForPrompt('en'),
    );
  }

  static String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 8) return '早晨';
    if (hour >= 8 && hour < 12) return '上午';
    if (hour >= 12 && hour < 14) return '中午';
    if (hour >= 14 && hour < 18) return '下午';
    if (hour >= 18 && hour < 20) return '傍晚';
    if (hour >= 20 && hour < 23) return '晚上';
    return '深夜';
  }
}

/// 天气/环境信息
class WeatherInfo {
  final String timeOfDay;
  final int? temperature;
  final bool isNight;
  final bool isDawn;
  final String? weatherDesc;
  final String? weatherDescEn;
  final String? windDesc;
  final String? windDescEn;
  final bool isRainy;
  final bool isSnowy;
  final bool isThunderstorm;
  /// 预格式化的 prompt 片段（中/英）
  final String? weatherForPrompt;
  final String? weatherForPromptEn;

  const WeatherInfo({
    required this.timeOfDay,
    required this.temperature,
    required this.isNight,
    required this.isDawn,
    this.weatherDesc,
    this.weatherDescEn,
    this.windDesc,
    this.windDescEn,
    this.isRainy = false,
    this.isSnowy = false,
    this.isThunderstorm = false,
    this.weatherForPrompt,
    this.weatherForPromptEn,
  });
}
