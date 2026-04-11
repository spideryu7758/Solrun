import 'audience_roles.dart';
import 'personalities.dart';
import 'mood_states.dart';
import 'voice_picker.dart';
import '../data/runner_profile_builder.dart';
import '../data/trigger_context_builder.dart';
import 'holiday_detector.dart';
import 'weather_detector.dart';

/// 观众喊话 Prompt 组装器（设计文档 6.x 节）
class ShoutPromptBuilder {
  ShoutPromptBuilder._();

  /// 组装完整的观众喊话 prompt
  ///
  /// [lang] 语言代码：'zh' 或 'en'
  /// [weatherInfo] 实时天气信息（可选，WeatherService 获取）
  static List<Map<String, String>> build({
    required VoiceCombo combo,
    required RunnerProfile profile,
    required TriggerContext triggerContext,
    required MoodState mood,
    required String lang,
    List<String> previousShouts = const [],
    DateTime? startTime,
    WeatherInfo? weatherInfo,
  }) {
    final isEn = lang == 'en';

    // 收集彩蛋/环境提示
    final easterEggs = <String>[];

    // ── 实时天气 ──
    if (weatherInfo != null) {
      final wp = isEn ? weatherInfo.weatherForPromptEn : weatherInfo.weatherForPrompt;
      if (wp != null && wp.isNotEmpty) {
        easterEggs.add(isEn
            ? 'Current weather: $wp'
            : '当前天气：$wp');
      }

      if (weatherInfo.isRainy) {
        easterEggs.add(isEn
            ? 'The runner is running in the rain. Weave in rainy imagery if it fits your character.'
            : '跑者正在雨中跑步。如果符合角色特征，可以自然融入雨天的意象。');
      }
      if (weatherInfo.isSnowy) {
        easterEggs.add(isEn
            ? 'The runner is running in the snow! If it fits your character, mention this.'
            : '跑者正在雪中跑步！如果符合角色特征，可以提及。');
      }
      if (weatherInfo.isThunderstorm) {
        easterEggs.add(isEn
            ? 'There\'s a thunderstorm! The runner is out in this weather.'
            : '正在打雷！跑者竟然在这种天气出门跑步。');
      }
    }

    // ── 时段彩蛋 ──
    if (startTime != null) {
      final info = weatherInfo ?? WeatherDetector.detect(startTime);
      if (info.isNight) {
        easterEggs.add(isEn
            ? 'Extra: The runner is running late at night (${info.timeOfDay}). Weave in nighttime imagery if it fits.'
            : '附加信息：跑者正在深夜（${info.timeOfDay}）跑步。如果符合角色特征，可以自然融入深夜的意象。');
      }
      if (info.isDawn) {
        easterEggs.add(isEn
            ? 'Extra: The runner is out at dawn (${info.timeOfDay}). Up before the sun.'
            : '附加信息：跑者在凌晨（${info.timeOfDay}）出门跑步，起得比太阳还早。');
      }

      // 节日彩蛋
      final holiday = HolidayDetector.detect(startTime);
      if (holiday != null) {
        easterEggs.add(isEn
            ? 'Extra: Today is $holiday. Weave in holiday elements naturally if it fits.'
            : '附加信息：今天是$holiday。如果符合角色特征，可以自然融入节日元素。');
      }
    }

    // ── 连续/回归跑彩蛋 ──
    if (profile.streakDays >= 7) {
      easterEggs.add(isEn
          ? 'Extra: ${profile.streakDays}-day running streak. Iron mode.'
          : '附加信息：跑者已连续跑步 ${profile.streakDays} 天，铁人模式。');
    }
    if (profile.daysSinceLastRun > 14) {
      easterEggs.add(isEn
          ? 'Extra: Haven\'t run for ${profile.daysSinceLastRun} days. This is a comeback run.'
          : '附加信息：跑者已 ${profile.daysSinceLastRun} 天没跑步了，今天是回归之跑。');
    }

    return [
      {'role': 'system', 'content': _systemPrompt(isEn)},
      {
        'role': 'user',
        'content': _userPrompt(combo, profile, triggerContext, mood, easterEggs, previousShouts, isEn),
      },
    ];
  }

  /// 系统 prompt
  static String _systemPrompt(bool isEn) {
    if (isEn) {
      return 'You are a spectator sitting in the stands at a sports stadium. '
          'You react in real-time to the runner\'s current performance based on your role and personality.\n\n'
          '[Output Rules]\n'
          '- Reply in English\n'
          '- Strictly 8-25 words\n'
          '- Must reference at least one specific data point (pace, distance, time, comparison, etc.)\n'
          '- Speak casually, like shouting from the stands\n'
          '- No generic cheers like "You got this!" or "You\'re the best!"\n'
          '- Output only the shout itself — no quotes, prefixes, role names, or extra text\n'
          '- If data is mediocre or bad, don\'t force positivity — stay in character\n'
          '- Never reuse themes, metaphors, imagery, or sentence patterns from previous shouts — each shout must take a completely fresh angle\n'
          '- Do not output any thinking process, analysis, or reasoning — give the final shout directly';
    }
    return '你是一位正在体育场观众席上看比赛的观众。'
        '你会根据自己角色的立场和人格特点，对跑者当前的跑步实况做出即时反应。\n\n'
        '【输出规则】\n'
        '- 必须用中文回复\n'
        '- 长度严格控制在 15-40 字之间\n'
        '- 必须引用至少一个具体数据点（配速、距离、时间、对比等）\n'
        '- 用口语化的方式说话，像在观众席上喊话\n'
        '- 不许用"加油""你是最棒的"等空话\n'
        '- 只输出喊话内容本身，不要加引号、前缀、角色名等任何额外文字\n'
        '- 如果数据一般或不好，不要强行正能量，保持角色真实性\n'
        '- 严禁重复之前喊话用过的主题、比喻、意象或句式，每条喊话必须切入全新角度\n'
        '- 不要输出任何思考过程、分析或推理，直接给出最终喊话内容';
  }

  /// 用户 prompt
  static String _userPrompt(
    VoiceCombo combo,
    RunnerProfile profile,
    TriggerContext triggerContext,
    MoodState mood,
    List<String> easterEggs,
    List<String> previousShouts,
    bool isEn,
  ) {
    final lang = isEn ? 'en' : 'zh';
    final buf = StringBuffer();

    buf.writeln(isEn ? '[Your Role]' : '【你的角色】');
    buf.writeln(combo.role.promptDescriptionFor(lang));
    buf.writeln();

    buf.writeln(isEn ? '[Your Speaking Style]' : '【你的说话风格】');
    buf.writeln(combo.personality.promptDescriptionFor(lang));
    buf.writeln();

    // 跑者画像截断到前 1500 字符，防止 prompt 过长超出 context window
    final profileText =
        RunnerProfileBuilder.formatForPrompt(profile, isEn: isEn);
    buf.writeln(profileText.length > 1500
        ? profileText.substring(0, 1500)
        : profileText);
    buf.writeln();

    buf.writeln(triggerContext.formatForPrompt(isEn: isEn));
    buf.writeln();

    buf.writeln(isEn ? '[Runner\'s Mood Today]' : '【跑者今日状态】');
    buf.writeln(mood.promptHintFor(lang));
    buf.writeln();

    // 彩蛋最多取前 3 个，避免 prompt 无限增长
    final limitedEggs =
        easterEggs.length > 3 ? easterEggs.sublist(0, 3) : easterEggs;
    if (limitedEggs.isNotEmpty) {
      buf.writeln(isEn ? '[Environment & Extra Info]' : '【环境与附加信息】');
      for (final egg in limitedEggs) {
        buf.writeln(egg);
      }
      buf.writeln();
    }

    // 历史喊话注入（最近 5 条，让 LLM 回避已用过的主题和表达）
    final recentShouts = previousShouts.length > 5
        ? previousShouts.sublist(previousShouts.length - 5)
        : previousShouts;
    if (recentShouts.isNotEmpty) {
      buf.writeln(isEn
          ? '[Previous Shouts This Run — DO NOT repeat their themes, metaphors, or patterns]'
          : '【本次跑步已有喊话 —— 严禁重复其中的主题、比喻或句式】');
      for (int i = 0; i < recentShouts.length; i++) {
        buf.writeln('${i + 1}. ${recentShouts[i]}');
      }
      buf.writeln();
    }

    if (isEn) {
      buf.writeln('As ${combo.role.displayName} with ${combo.personality.displayName} style, '
          'react to the situation above. Take a completely different angle from any previous shouts.');
    } else {
      buf.writeln('请以${combo.role.displayName}·${combo.personality.displayName}的身份，'
          '针对以上实况做出你的即时反应。必须用与之前喊话完全不同的角度和表达方式。');
    }

    return buf.toString();
  }
}
