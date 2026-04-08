import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/audience/domain/holiday_detector.dart';

void main() {
  group('HolidayDetector', () {
    group('公历节日', () {
      test('1月1日 → 元旦', () {
        expect(HolidayDetector.detect(DateTime(2025, 1, 1)), equals('元旦'));
      });

      test('2月14日 → 情人节', () {
        expect(HolidayDetector.detect(DateTime(2025, 2, 14)), equals('情人节'));
      });

      test('5月1日 → 劳动节', () {
        expect(HolidayDetector.detect(DateTime(2026, 5, 1)), equals('劳动节'));
      });

      test('10月1日 → 国庆节', () {
        expect(HolidayDetector.detect(DateTime(2025, 10, 1)), equals('国庆节'));
      });

      test('12月25日 → 圣诞节', () {
        expect(HolidayDetector.detect(DateTime(2025, 12, 25)), equals('圣诞节'));
      });

      test('公历节日跨年份通用（任意年 1 月 1 日都是元旦）', () {
        expect(HolidayDetector.detect(DateTime(2030, 1, 1)), equals('元旦'));
        expect(HolidayDetector.detect(DateTime(2050, 1, 1)), equals('元旦'));
      });
    });

    group('农历节日（基于映射表）', () {
      test('2025年春节 → 1月29日', () {
        expect(HolidayDetector.detect(DateTime(2025, 1, 29)), equals('春节'));
      });

      test('2025年除夕 → 1月28日', () {
        expect(HolidayDetector.detect(DateTime(2025, 1, 28)), equals('除夕'));
      });

      test('2025年端午节 → 5月31日', () {
        expect(HolidayDetector.detect(DateTime(2025, 5, 31)), equals('端午节'));
      });

      test('2025年中秋节 → 10月6日', () {
        expect(HolidayDetector.detect(DateTime(2025, 10, 6)), equals('中秋节'));
      });

      test('2026年春节 → 2月17日', () {
        expect(HolidayDetector.detect(DateTime(2026, 2, 17)), equals('春节'));
      });

      test('2029年中秋节 → 10月1日（与国庆同日，公历优先）', () {
        // 公历节日优先匹配，2029年10月1日既是国庆也是中秋
        // 代码中先匹配公历，所以返回国庆节
        expect(HolidayDetector.detect(DateTime(2029, 10, 1)), equals('国庆节'));
      });
    });

    group('普通日期', () {
      test('普通工作日 → 返回 null', () {
        expect(HolidayDetector.detect(DateTime(2025, 3, 12)), isNull);
      });

      test('普通周末 → 返回 null（detect 不检测周末）', () {
        // 2025年3月15日是周六
        expect(HolidayDetector.detect(DateTime(2025, 3, 15)), isNull);
      });
    });

    group('超出映射范围的年份', () {
      test('2024年（映射表之前）→ 仅匹配公历，农历静默跳过', () {
        // 2024年1月29日不在映射表中，也不是公历节日
        expect(HolidayDetector.detect(DateTime(2024, 1, 29)), isNull);
        // 公历节日仍然可用
        expect(HolidayDetector.detect(DateTime(2024, 1, 1)), equals('元旦'));
      });

      test('2035年（映射表之后）→ 仅匹配公历，农历静默跳过', () {
        expect(HolidayDetector.detect(DateTime(2035, 3, 15)), isNull);
        expect(HolidayDetector.detect(DateTime(2035, 5, 1)), equals('劳动节'));
      });

      test('极端年份不崩溃', () {
        // 不应抛出异常
        expect(HolidayDetector.detect(DateTime(1900, 6, 15)), isNull);
        expect(HolidayDetector.detect(DateTime(2100, 6, 15)), isNull);
      });
    });

    group('isWeekend', () {
      test('周六 → true', () {
        // 2025年4月5日是周六
        expect(HolidayDetector.isWeekend(DateTime(2025, 4, 5)), isTrue);
      });

      test('周日 → true', () {
        // 2025年4月6日是周日
        expect(HolidayDetector.isWeekend(DateTime(2025, 4, 6)), isTrue);
      });

      test('周一 → false', () {
        // 2025年4月7日是周一
        expect(HolidayDetector.isWeekend(DateTime(2025, 4, 7)), isFalse);
      });

      test('周五 → false', () {
        // 2025年4月4日是周五
        expect(HolidayDetector.isWeekend(DateTime(2025, 4, 4)), isFalse);
      });
    });
  });
}
