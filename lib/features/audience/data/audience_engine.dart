import 'dart:async';

import 'package:characters/characters.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart' hide ChatMessage;
import '../../../data/daos/audience_favorite_dao.dart';
import '../../../data/daos/audience_shout_dao.dart';
import '../../../data/daos/audience_unlock_dao.dart';
import '../../../shared/services/llm/llm_models.dart';
import '../../../shared/services/llm/llm_provider.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../../../app/locale_provider.dart';
import '../domain/weather_detector.dart';
import '../domain/audience_constants.dart';
import '../domain/audience_roles.dart';
import '../domain/mood_states.dart';
import '../domain/personalities.dart';
import '../domain/shout_prompt_builder.dart';
import '../domain/voice_picker.dart';
import 'runner_profile_builder.dart';
import 'trigger_context_builder.dart';

/// 观众喊话结果
class ShoutResult {
  final String content;
  final AudienceRole role;
  final Personality personality;
  final int shoutId;

  const ShoutResult({
    required this.content,
    required this.role,
    required this.personality,
    required this.shoutId,
  });
}

/// 观众引擎核心服务
///
/// 职责：抽取角色 → 组装 prompt → 调用 LLM → 存库 → 返回喊话
/// 特性：超时、失败静默、并发互斥、AI 未配置时返回 null
class AudienceEngine {
  final Ref _ref;
  final AudienceShoutDao _shoutDao;
  final AudienceFavoriteDao _favoriteDao;
  final AudienceUnlockDao _unlockDao;

  /// 并发互斥锁：上一次请求未完成时跳过新触发
  /// 使用 Completer 代替布尔值，在异步环境下安全地防止并发请求
  Completer<void>? _processing;

  AudienceEngine(
    this._ref, {
    required AudienceShoutDao shoutDao,
    required AudienceFavoriteDao favoriteDao,
    required AudienceUnlockDao unlockDao,
  }) : _shoutDao = shoutDao,
       _favoriteDao = favoriteDao,
       _unlockDao = unlockDao;

  /// 生成一条观众喊话
  Future<ShoutResult?> generateShout({
    required TriggerType triggerType,
    required TriggerContext triggerContext,
    required RunnerProfile profile,
    required MoodState mood,
    required int sessionId,
    List<String> previousShouts = const [],
    DateTime? startTime,
    WeatherInfo? weatherInfo,
  }) async {
    // 1. 并发互斥检查
    if (_processing != null && !_processing!.isCompleted) return null;
    _processing = Completer<void>();

    try {
      // 2. AI 可用性检查（含异步等待配置加载）
      final llm = await _getActiveLlm();
      if (llm == null) return null;

      // 3. 获取已解锁角色
      final unlockedRoles = await _getUnlockedRoles();
      if (unlockedRoles.isEmpty) return null;

      // 4. 获取粉丝团角色
      final fanTeamRoles = await _getFanTeamRoles();

      // 5. 抽取角色组合
      final combo = VoicePicker.pickRandomVoice(
        mood: mood,
        unlockedRoles: unlockedRoles,
        fanTeamRoles: fanTeamRoles,
      );

      // 6. 组装 prompt（根据当前语言选择中/英文 prompt）
      final locale = _ref.read(localeProvider);
      final lang = locale?.languageCode ?? 'zh';
      final messages = ShoutPromptBuilder.build(
        combo: combo,
        profile: profile,
        triggerContext: triggerContext,
        mood: mood,
        lang: lang,
        previousShouts: previousShouts,
        startTime: startTime,
        weatherInfo: weatherInfo,
      );

      // 7. 调用 LLM
      final chatMessages = messages
          .map(
            (m) => ChatMessage(
              role: m['role'] == 'system' ? ChatRole.system : ChatRole.user,
              content: m['content'] ?? '',
            ),
          )
          .toList();

      const config = LlmConfig(
        temperature: AudienceConstants.llmTemperature,
        maxTokens: AudienceConstants.maxLlmTokens,
      );

      final response = await _callStream(llm, chatMessages, config);

      // 8. 后处理：剥离推理模型的 <think> 块 + 截断过长内容
      var content = _stripThinkTags(response).trim();
      if (content.isEmpty) return null;
      final maxLen = lang == 'en'
          ? AudienceConstants.maxShoutLengthEn
          : AudienceConstants.maxShoutLengthZh;
      if (content.characters.length > maxLen) {
        content = '${content.characters.take(maxLen)}…';
      }

      // 9. 存入数据库
      final shoutId = await _saveShout(
        sessionId: sessionId,
        role: combo.role,
        personality: combo.personality,
        triggerType: triggerType,
        triggerKm: triggerContext.triggerKm,
        content: content,
        triggerContext: triggerContext,
      );

      return ShoutResult(
        content: content,
        role: combo.role,
        personality: combo.personality,
        shoutId: shoutId,
      );
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    } finally {
      _processing?.complete();
    }
  }

  /// 流式 LLM 调用 —— 实时剥离 `<think>` 块，思考结束后立即返回内容
  ///
  /// 相比 complete()，优势在于：
  /// - `<think>` 阶段的 token 边收边丢，不等完整响应
  /// - `</think>` 后的实际内容一拼完就返回，不等 finish_reason
  /// - 429 限频自动重试一次
  Future<String> _callStream(
    LlmProvider llm,
    List<ChatMessage> messages,
    LlmConfig config,
  ) async {
    Future<String> doCall() async {
      final stream = llm.completeStream(messages, config: config);
      final buf = StringBuffer();
      bool inThink = false;
      bool thinkDone = false;

      await for (final token in stream.timeout(
        Duration(seconds: AudienceConstants.llmTimeoutSeconds),
      )) {
        if (!thinkDone) {
          // 检测 <think> 开始
          if (!inThink && token.contains('<think>')) {
            inThink = true;
            // <think> 标签前可能有内容
            final before = token.split('<think>').first.trim();
            if (before.isNotEmpty) buf.write(before);
            continue;
          }
          // <think> 阶段中，检测 </think> 结束
          if (inThink) {
            if (token.contains('</think>')) {
              thinkDone = true;
              final after = token.split('</think>').last.trim();
              if (after.isNotEmpty) buf.write(after);
            }
            continue; // 丢弃思考 token
          }
        }
        // 非 think 内容，正常收集
        buf.write(token);
      }

      return buf.toString();
    }

    try {
      return await doCall();
    } on LlmRateLimitException {
      await Future.delayed(const Duration(seconds: 8));
      return await doCall();
    } on LlmException catch (e) {
      // 529 服务过载也重试一次
      if (e.statusCode == 529) {
        await Future.delayed(const Duration(seconds: 8));
        return await doCall();
      }
      rethrow;
    }
  }

  /// 剥离推理模型的 `<think>...</think>` 思考块（用于非流式结果的兜底处理）
  static String _stripThinkTags(String text) {
    final closed = RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false);
    var result = text.replaceAll(closed, '');
    final open = RegExp(r'<think>[\s\S]*$', caseSensitive: false);
    result = result.replaceAll(open, '');
    return result;
  }

  /// 获取激活的 LLM 实例
  ///
  /// `activeLlmProvider` 依赖 `llmConfigProvider`（FutureProvider），
  /// 首次读取时配置可能尚未加载完成。此方法先尝试同步读取，
  /// 若为 null 则 await 配置加载后重试。
  Future<LlmProvider?> _getActiveLlm() async {
    final llm = _ref.read(activeLlmProvider);
    if (llm != null) return llm;

    // 配置可能尚未加载，等待 FutureProvider 完成
    try {
      await _ref.read(llmConfigProvider.future);
      return _ref.read(activeLlmProvider);
    } catch (_) {
      return null;
    }
  }

  /// 获取已解锁角色集合
  Future<Set<AudienceRole>> _getUnlockedRoles() async {
    final roleNames = await _unlockDao.getUnlockedRoles();
    return roleNames.map((name) => AudienceRole.fromName(name)).toSet();
  }

  /// 获取粉丝团角色集合
  Future<Set<AudienceRole>> _getFanTeamRoles() async {
    final favorites = await _favoriteDao.getAll();
    return favorites.map((f) => AudienceRole.fromName(f.audienceRole)).toSet();
  }

  /// 保存喊话记录到数据库
  Future<int> _saveShout({
    required int sessionId,
    required AudienceRole role,
    required Personality personality,
    required TriggerType triggerType,
    required int? triggerKm,
    required String content,
    required TriggerContext triggerContext,
  }) async {
    return _shoutDao.insertShout(
      AudienceShoutsCompanion.insert(
        sessionId: sessionId,
        audienceRole: role.name,
        personality: personality.name,
        triggerType: triggerType.name,
        triggerKm: Value(triggerKm),
        content: content,
        triggerContext: triggerContext.formatForPrompt(),
        createdAt: DateTime.now(),
      ),
    );
  }
}
