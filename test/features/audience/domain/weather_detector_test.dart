import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/audience/domain/weather_detector.dart';
import 'package:run_pure/shared/services/weather_service.dart';

void main() {
  group('WeatherDetector', () {
    group('时段检测（timeOfDay）', () {
      test('凌晨 3 点 → 深夜', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 3, 0));
        expect(info.timeOfDay, equals('深夜'));
      });

      test('凌晨 5 点 → 早晨', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 5, 0));
        expect(info.timeOfDay, equals('早晨'));
      });

      test('上午 9 点 → 上午', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 9, 0));
        expect(info.timeOfDay, equals('上午'));
      });

      test('中午 12 点 → 中午', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 12, 0));
        expect(info.timeOfDay, equals('中午'));
      });

      test('下午 15 点 → 下午', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 15, 0));
        expect(info.timeOfDay, equals('下午'));
      });

      test('傍晚 19 点 → 傍晚', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 19, 0));
        expect(info.timeOfDay, equals('傍晚'));
      });

      test('晚上 21 点 → 晚上', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 21, 0));
        expect(info.timeOfDay, equals('晚上'));
      });

      test('深夜 23 点 → 深夜', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 23, 0));
        expect(info.timeOfDay, equals('深夜'));
      });

      test('午夜 0 点 → 深夜', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 0, 0));
        expect(info.timeOfDay, equals('深夜'));
      });
    });

    group('深夜/凌晨彩蛋标志', () {
      test('深夜 0-4 点 → isNight=true, isDawn=false', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 2, 0));
        expect(info.isNight, isTrue);
        expect(info.isDawn, isFalse);
      });

      test('凌晨 4 点 → isNight=true（23-5范围内）且 isDawn=true（4-6范围内）', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 4, 0));
        expect(info.isNight, isTrue);
        expect(info.isDawn, isTrue);
      });

      test('凌晨 5 点 → isNight=false（不在23-5范围）且 isDawn=true', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 5, 0));
        expect(info.isNight, isFalse);
        expect(info.isDawn, isTrue);
      });

      test('上午 8 点 → isNight=false, isDawn=false', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 8, 0));
        expect(info.isNight, isFalse);
        expect(info.isDawn, isFalse);
      });

      test('晚上 23 点 → isNight=true, isDawn=false', () {
        final info = WeatherDetector.detect(DateTime(2025, 6, 15, 23, 0));
        expect(info.isNight, isTrue);
        expect(info.isDawn, isFalse);
      });
    });

    group('天气数据传递', () {
      test('无天气数据（weather=null）→ 温度为 null，天气标志全 false', () {
        final info = WeatherDetector.detect(
          DateTime(2025, 6, 15, 10, 0),
        );
        expect(info.temperature, isNull);
        expect(info.isRainy, isFalse);
        expect(info.isSnowy, isFalse);
        expect(info.isThunderstorm, isFalse);
        expect(info.weatherDesc, isNull);
      });

      test('高温天气（>35°C）→ 温度正确传递', () {
        final weather = WeatherResult(
          temperature: 38.5,
          weatherCode: 0, // 晴
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 7, 20, 14, 0),
          weather: weather,
        );
        expect(info.temperature, equals(39)); // 38.5 → round() = 39（int? 转换）
      });

      test('寒冷天气（<0°C）→ 温度正确传递', () {
        final weather = WeatherResult(
          temperature: -5.3,
          weatherCode: 71, // 小雪
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 1, 15, 7, 0),
          weather: weather,
        );
        expect(info.temperature, equals(-5)); // -5.3 → round() = -5
      });

      test('雨天（weatherCode 51-67）→ isRainy=true', () {
        final weather = WeatherResult(
          temperature: 15.0,
          weatherCode: 61, // 小雨
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 4, 10, 10, 0),
          weather: weather,
        );
        expect(info.isRainy, isTrue);
        expect(info.isSnowy, isFalse);
      });

      test('雪天（weatherCode 71-77）→ isSnowy=true', () {
        final weather = WeatherResult(
          temperature: -2.0,
          weatherCode: 73, // 中雪
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 12, 20, 8, 0),
          weather: weather,
        );
        expect(info.isSnowy, isTrue);
        expect(info.isRainy, isFalse);
      });

      test('雷暴（weatherCode >= 95）→ isThunderstorm=true', () {
        final weather = WeatherResult(
          temperature: 25.0,
          weatherCode: 95,
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 8, 5, 16, 0),
          weather: weather,
        );
        expect(info.isThunderstorm, isTrue);
      });

      test('晴天（weatherCode 0）→ 无特殊天气标志', () {
        final weather = WeatherResult(
          temperature: 22.0,
          weatherCode: 0,
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 5, 1, 9, 0),
          weather: weather,
        );
        expect(info.isRainy, isFalse);
        expect(info.isSnowy, isFalse);
        expect(info.isThunderstorm, isFalse);
        expect(info.weatherDesc, equals('晴'));
      });

      test('天气描述字段正确传递', () {
        final weather = WeatherResult(
          temperature: 20.0,
          weatherCode: 61,
          windSpeedKmh: 15.0,
        );
        final info = WeatherDetector.detect(
          DateTime(2025, 5, 1, 9, 0),
          weather: weather,
        );
        expect(info.weatherDesc, equals('小雨'));
        expect(info.weatherDescEn, equals('Light rain'));
        expect(info.windDesc, equals('和风'));
        expect(info.windDescEn, equals('moderate wind'));
      });
    });
  });
}
