import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/data/database.dart';
import 'package:run_pure/features/audience/domain/audience_roles.dart';
import 'package:run_pure/features/audience/domain/holiday_detector.dart';
import 'package:run_pure/features/audience/domain/interview_prompt_builder.dart';
import 'package:run_pure/features/audience/domain/mood_states.dart';
import 'package:run_pure/features/audience/domain/personalities.dart';
import 'package:run_pure/features/audience/domain/shout_prompt_builder.dart';
import 'package:run_pure/features/audience/domain/voice_picker.dart';
import 'package:run_pure/features/audience/data/runner_profile_builder.dart';
import 'package:run_pure/features/audience/domain/unlock_checker.dart';
import 'package:run_pure/features/audience/domain/weather_detector.dart';
import 'package:run_pure/features/audience/data/trigger_context_builder.dart';
import 'package:run_pure/features/audience/presentation/interview_notifier.dart';

void main() {
  const sampleProfile = RunnerProfile(
    totalRuns: 12,
    totalDistanceKm: 68.5,
    totalDurationSec: 25200,
    streakDays: 8,
    daysSinceLastRun: 1,
    bestPaceSecPerKm: 320,
    worstPaceSecPerKm: 410,
    longestRunKm: 12.0,
    shortestRunKm: 3.0,
    best5kTimeSec: 1500,
    best10kTimeSec: 3300,
    weeklyDistances: [18, 16, 20, 14],
    weeklyCounts: [3, 3, 4, 2],
    recentAvgPaceSecPerKm: 355,
    recentAvgDistanceKm: 5.7,
    paceTrend: 'improving',
    monthDistanceKm: 34.0,
    monthRuns: 6,
    monthAvgPaceSecPerKm: 350,
    preferredTime: 'morning',
    preferredDistance: '5k',
    avgRunsPerWeek: 3.0,
    hasHistory: true,
  );

  group('WeatherDetector', () {
    test('凌晨时间会标记夜间和黎明', () {
      final info = WeatherDetector.detect(DateTime(2026, 7, 1, 4, 30));

      expect(info.isNight, isTrue);
      expect(info.isDawn, isTrue);
    });

    test('晚上时间不会标记黎明', () {
      final info = WeatherDetector.detect(DateTime(2026, 7, 1, 21));

      expect(info.isNight, isFalse);
      expect(info.isDawn, isFalse);
    });
  });

  group('HolidayDetector', () {
    test('识别公历节日和周末', () {
      expect(HolidayDetector.detect(DateTime(2026, 10, 1)), '国庆节');
      expect(HolidayDetector.isWeekend(DateTime(2026, 10, 3)), isTrue);
    });

    test('识别配置内的农历映射日期', () {
      // 2026 年中秋对应公历 9-25（农历八月十五）
      expect(HolidayDetector.detect(DateTime(2026, 9, 25)), '中秋节');
    });
  });

  group('UnlockChecker', () {

    test('达到阈值时只解锁未拥有角色', () async {
      // UnlockChecker 现在是纯函数，不再直接操作 DAO
      final unlocked = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: {},
      );

      expect(
        unlocked,
        [AudienceRole.gambler, AudienceRole.nitpicker, AudienceRole.rivalFan],
      );

      // 模拟第二次调用：已解锁的角色不会重复返回
      final secondRun = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: unlocked.map((r) => r.name).toSet(),
      );
      expect(secondRun, isEmpty);
    });
  });

  group('InterviewNotifier', () {
    test('conversation id 按 session + role + personality 隔离', () {
      final first = InterviewNotifier.buildConversationId(
        42,
        AudienceRole.screamingFan,
        Personality.clown,
      );
      final second = InterviewNotifier.buildConversationId(
        42,
        AudienceRole.dataNerd,
        Personality.clown,
      );

      expect(first, 'interview_42_screamingFan_clown');
      expect(second, 'interview_42_dataNerd_clown');
      expect(first, isNot(second));
    });

    test('只保留当前采访角色的人设喊话', () {
      final filtered = InterviewNotifier.filterShoutsForSpeaker([
        AudienceShout(
          id: 1,
          sessionId: 9,
          audienceRole: AudienceRole.screamingFan.name,
          personality: Personality.clown.name,
          triggerType: 'finish',
          content: '你今天终于冲起来了',
          isFavorite: false,
          triggerContext: '{}',
          createdAt: DateTime(2026, 4, 1, 8),
        ),
        AudienceShout(
          id: 2,
          sessionId: 9,
          audienceRole: AudienceRole.dataNerd.name,
          personality: Personality.commentator.name,
          triggerType: 'finish',
          content: '最后一公里数据不够稳定',
          isFavorite: false,
          triggerContext: '{}',
          createdAt: DateTime(2026, 4, 1, 8, 1),
        ),
      ], AudienceRole.screamingFan, Personality.clown);

      final prompt = InterviewPromptBuilder.build(
        role: AudienceRole.screamingFan,
        personality: Personality.clown,
        profile: sampleProfile,
        session: RunSession(
          id: 9,
          status: 'completed',
          startTime: DateTime(2026, 4, 1, 7),
          endTime: DateTime(2026, 4, 1, 7, 30),
          durationSeconds: 1800,
          distanceMeters: 5000,
          avgPaceSecPerKm: 360,
          bestPaceSecPerKm: 330,
          caloriesKcal: 320,
          elevationGainMeters: 20,
          autoName: '晨跑 5K',
        ),
        shouts: filtered,
        chatHistory: const [],
      );

      expect(prompt.first['content'], contains('你今天终于冲起来了'));
      expect(prompt.first['content'], isNot(contains('最后一公里数据不够稳定')));
    });
  });

  group('ShoutPromptBuilder', () {
    test('传入 startTime 时会加入天气和节日彩蛋', () {
      final prompt = ShoutPromptBuilder.build(
        combo: const VoiceCombo(
          role: AudienceRole.familyCrew,
          personality: Personality.poet,
        ),
        profile: sampleProfile,
        triggerContext: TriggerContext(
          triggerType: TriggerType.start,
          currentKm: 0,
          currentKmPaceSecPerKm: 0,
          currentAvgPaceSecPerKm: 0,
          currentDistanceKm: 0,
          currentDurationSec: 0,
          splitPacesSecPerKm: const [],
          timeOfDay: '凌晨',
        ),
        mood: MoodState.provoke,
        lang: 'zh',
        startTime: DateTime(2026, 10, 1, 4, 30),
      );

      // prompt 包含 system + user 消息，彩蛋和档案分布在不同位置
      final allContent = prompt.map((m) => m['content']!).join('\n');
      expect(allContent, contains('国庆节'));
      expect(allContent, contains('深夜'));
      expect(allContent, contains('凌晨'));
      // '连续跑步 8 天' 出现在跑者档案中（easterEggs 截断为 3 条时可能不含此项）
      expect(allContent, contains('连续跑步 8 天'));
    });
  });
}
