import '../../../data/database.dart';
import '../../../shared/utils/run_format_utils.dart';
import 'audience_roles.dart';
import 'personalities.dart';
import '../data/runner_profile_builder.dart';

/// 赛后采访 Prompt 组装器
class InterviewPromptBuilder {
  InterviewPromptBuilder._();

  /// 组装赛后采访 prompt
  ///
  /// [lang] 语言代码：'zh' 或 'en'
  static List<Map<String, String>> build({
    required AudienceRole role,
    required Personality personality,
    required RunnerProfile profile,
    required RunSession session,
    required List<AudienceShout> shouts,
    required List<Map<String, String>> chatHistory,
    String lang = 'zh',
  }) {
    final systemPrompt = _buildSystemPrompt(role, personality, profile, session, shouts, lang);
    final historyToInclude = chatHistory.length > 20
        ? chatHistory.sublist(chatHistory.length - 20)
        : chatHistory;

    return [
      {'role': 'system', 'content': systemPrompt},
      ...historyToInclude,
    ];
  }

  static String _buildSystemPrompt(
    AudienceRole role,
    Personality personality,
    RunnerProfile profile,
    RunSession session,
    List<AudienceShout> shouts,
    String lang,
  ) {
    final isEn = lang == 'en';
    final buf = StringBuffer();

    if (isEn) {
      buf.writeln('You were just watching a runner\'s entire run from the spectator stands of a live running event. '
          'The race is over now, and the runner has come over for a "post-race interview" with you.');
      buf.writeln();
      buf.writeln('## Your Identity');
      buf.writeln('- Role: ${role.promptDescriptionFor(lang)}');
      buf.writeln('- Speaking style: ${personality.promptDescriptionFor(lang)}');
    } else {
      buf.writeln('你刚才在一场跑步直播比赛的观众席上观看跑者的完整跑步过程，现在比赛结束了，跑者走过来接受你的"赛后采访"。');
      buf.writeln();
      buf.writeln('## 你的身份');
      buf.writeln('- 观众角色：${role.promptDescription}');
      buf.writeln('- 说话风格：${personality.promptDescription}');
    }
    buf.writeln();

    // 比赛中的喊话记录
    buf.writeln(isEn ? '## Your Shouts During the Race' : '## 你在比赛中的喊话记录');
    if (shouts.isNotEmpty) {
      // 截断到最近 20 条，避免 prompt 超出 context window
      final recentShouts = shouts.length > 20
          ? shouts.sublist(shouts.length - 20)
          : shouts;
      for (final s in recentShouts) {
        final r = AudienceRole.fromName(s.audienceRole);
        final p = Personality.fromName(s.personality);
        if (isEn) {
          buf.writeln('${r.displayName} · ${p.displayName}: "${s.content}"');
        } else {
          buf.writeln('${r.displayName}·${p.displayName}："${s.content}"');
        }
      }
    } else {
      buf.writeln(isEn ? '(No shouts recorded this session)' : '（本场无喊话记录）');
    }
    buf.writeln();

    // 跑者完整数据
    buf.writeln(isEn ? '## Runner Profile' : '## 跑者完整数据');
    buf.writeln(RunnerProfileBuilder.formatForPrompt(profile, isEn: isEn));
    buf.writeln();

    // 本次跑步数据
    if (isEn) {
      buf.writeln('## This Run');
      buf.writeln('- Distance: ${(session.distanceMeters / 1000).toStringAsFixed(2)} km');
      buf.writeln('- Duration: ${RunFormatUtils.formatDuration(session.durationSeconds)}');
      buf.writeln('- Avg Pace: ${RunFormatUtils.formatPace(session.avgPaceSecPerKm)}/km');
      buf.writeln('- Best Pace: ${RunFormatUtils.formatPace(session.bestPaceSecPerKm)}/km');
      buf.writeln('- Elevation Gain: ${session.elevationGainMeters.toStringAsFixed(0)} m');
      buf.writeln('- Calories: ${session.caloriesKcal} kcal');
    } else {
      buf.writeln('## 本次跑步数据');
      buf.writeln('- 距离：${(session.distanceMeters / 1000).toStringAsFixed(2)} km');
      buf.writeln('- 用时：${RunFormatUtils.formatDuration(session.durationSeconds)}');
      buf.writeln('- 平均配速：${RunFormatUtils.formatPace(session.avgPaceSecPerKm)}/km');
      buf.writeln('- 最佳配速：${RunFormatUtils.formatPace(session.bestPaceSecPerKm)}/km');
      buf.writeln('- 海拔爬升：${session.elevationGainMeters.toStringAsFixed(0)} m');
      buf.writeln('- 卡路里：${session.caloriesKcal} kcal');
    }
    buf.writeln();

    if (isEn) {
      buf.writeln('## Conversation Rules');
      buf.writeln('- Stay in character — maintain your role traits and speaking style at all times.');
      buf.writeln('- You are a spectator, not a coach. You can comment on, tease, or question the runner\'s performance, but don\'t give professional training plans.');
      buf.writeln('- Keep replies to 2-4 sentences to maintain conversational flow.');
      buf.writeln('- Feel free to reference things you shouted during the race.');
      buf.writeln('- Sound natural and casual, like chatting by the track after a race — not like reading from a script.');
      buf.writeln('- Reply in English.');
    } else {
      buf.writeln('## 对话规则');
      buf.writeln('- 保持你的角色特征和说话风格，始终在"角色"内对话。');
      buf.writeln('- 你是观众，不是教练。可以评价、调侃、质疑跑者表现，但不给专业训练计划。');
      buf.writeln('- 回复控制在 2-4 句话以内，保持对话节奏。');
      buf.writeln('- 可以引用你在比赛中喊过的话来延续话题。');
      buf.writeln('- 语气自然口语化，像赛后跑道边的闲聊，不要像采访稿。');
      buf.writeln('- 用中文回复。');
    }

    return buf.toString();
  }
}
