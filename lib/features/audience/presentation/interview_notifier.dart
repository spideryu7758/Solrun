import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/daos/chat_dao.dart';
import '../../../data/database.dart' as db;
import '../../../data/providers.dart';
import '../../../shared/services/llm/llm_models.dart' as llm_models;
import '../../../app/locale_provider.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../data/runner_profile_builder.dart';
import '../domain/audience_roles.dart';
import '../domain/interview_prompt_builder.dart';
import '../domain/personalities.dart';
import 'interview_state.dart';

/// 赛后采访 Notifier — 管理采访对话的发送、流式接收和持久化
class InterviewNotifier extends StateNotifier<InterviewState> {
  static const _streamTimeout = Duration(seconds: 30);
  static const _databaseTimeout = Duration(seconds: 5);

  final Ref _ref;
  final int _sessionId;
  final AudienceRole _role;
  final Personality _personality;

  String _conversationId;
  StreamSubscription<String>? _streamSub;

  InterviewNotifier(
    this._ref,
    this._sessionId,
    this._role,
    this._personality,
  )   : _conversationId =
            buildConversationId(_sessionId, _role, _personality),
        super(const InterviewState());

  @visibleForTesting
  static String buildConversationId(
    int sessionId,
    AudienceRole role,
    Personality personality,
  ) =>
      'interview_${sessionId}_${role.name}_${personality.name}';

  @visibleForTesting
  static List<db.AudienceShout> filterShoutsForSpeaker(
    List<db.AudienceShout> shouts,
    AudienceRole role,
    Personality personality,
  ) =>
      shouts
          .where((s) =>
              s.audienceRole == role.name &&
              s.personality == personality.name)
          .toList();

  /// 初始化：加载历史对话或生成开场白
  Future<void> initialize() async {
    try {
      final chatDao = _ref.read(chatDaoProvider);

      // 尝试加载已有对话
      final existing = await chatDao.getConversation(_conversationId);
      if (existing.isNotEmpty) {
        _conversationId = existing.first.conversationId;
        state = state.copyWith(
          messages: existing
              .where((m) => m.role != 'system')
              .map((m) => InterviewMessage(
                    role: m.role,
                    content: m.content,
                    createdAt: m.createdAt,
                  ))
              .toList(),
        );
        return;
      }

      // 无历史对话，生成开场白
      await _generateOpening(chatDao);
    } catch (e) {
      state = state.copyWith(error: '加载采访记录失败: $e');
    }
  }

  /// 自动生成开场白
  Future<void> _generateOpening(ChatDao chatDao) async {
    final llm = _ref.read(activeLlmProvider);
    if (llm == null) {
      state = state.copyWith(error: '请先配置 AI 服务');
      return;
    }

    state = state.copyWith(isStreaming: true);

    try {
      final promptMessages = await _buildPromptMessages([]);
      _appendPlaceholder();

      final stream = llm.completeStream(
        promptMessages,
        config: const llm_models.LlmConfig(temperature: 0.9, maxTokens: 200),
      );

      await _consumeStream(stream, chatDao);
    } catch (e) {
      state = state.copyWith(
        isStreaming: false,
        error: e is llm_models.LlmException ? e.message : '$e',
      );
      _removeEmptyLastMessage();
    }
  }

  /// 发送用户消息并获取 AI 回复
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;

    final llm = _ref.read(activeLlmProvider);
    if (llm == null) {
      state = state.copyWith(error: '请先配置 AI 服务');
      return;
    }

    final chatDao = _ref.read(chatDaoProvider);
    final trimmed = text.trim();

    // 添加用户消息
    final userMsg = InterviewMessage(
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );
    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updatedMessages,
      input: '',
      error: null,
    );

    // 持久化用户消息
    try {
      await _persistMessage(chatDao, 'user', trimmed);
    } catch (e) {
      state = state.copyWith(error: '保存采访记录失败: $e');
      return;
    }

    // 生成 AI 回复
    state = state.copyWith(isStreaming: true);
    try {
      final promptMessages = await _buildPromptMessages(updatedMessages);
      _appendPlaceholder();

      final stream = llm.completeStream(
        promptMessages,
        config: const llm_models.LlmConfig(temperature: 0.9, maxTokens: 300),
      );

      await _consumeStream(stream, chatDao);
    } catch (e) {
      state = state.copyWith(
        isStreaming: false,
        error: e is llm_models.LlmException ? e.message : '$e',
      );
      _removeEmptyLastMessage();
    }
  }

  /// 消费 LLM stream：实时更新最后一条消息 → 完成后持久化
  Future<void> _consumeStream(Stream<String> stream, ChatDao chatDao) async {
    final buffer = StringBuffer();
    final completer = Completer<void>();

    await _cancelActiveStream();

    _streamSub = stream.listen(
      (token) {
        if (!mounted) return;
        buffer.write(token);
        _updateLastMessage(buffer.toString());
      },
      onDone: () async {
        if (mounted) state = state.copyWith(isStreaming: false);
        if (!completer.isCompleted) completer.complete();
        try {
          await _persistAssistant(chatDao, buffer.toString());
        } catch (_) {
          // _persistAssistant 内部已处理错误并更新 state
        }
      },
      onError: (e) {
        if (mounted) {
          state = state.copyWith(
            isStreaming: false,
            error: e is llm_models.LlmException ? e.message : '$e',
          );
          _removeEmptyLastMessage();
        }
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    // 超时保护：超时后取消流并保留已接收内容
    try {
      await completer.future.timeout(_streamTimeout);
    } on TimeoutException {
      await _cancelActiveStream();
      if (mounted) state = state.copyWith(isStreaming: false);
      final content = buffer.toString().trim();
      if (content.isNotEmpty) {
        try {
          await _persistAssistant(chatDao, content);
        } catch (_) {
          // _persistAssistant 内部已处理错误并更新 state
        }
      } else {
        _removeEmptyLastMessage();
      }
    }
  }

  /// 停止流式生成
  Future<void> stop() async {
    if (!state.isStreaming) return;

    final chatDao = _ref.read(chatDaoProvider);
    final lastMessage = state.messages.isNotEmpty ? state.messages.last : null;

    await _cancelActiveStream();
    state = state.copyWith(isStreaming: false);

    if (lastMessage?.role != 'assistant') return;

    final content = lastMessage!.content.trim();
    if (content.isEmpty) {
      _removeEmptyLastMessage();
      return;
    }

    try {
      await _persistAssistant(chatDao, content);
    } catch (_) {
      // _persistAssistant 内部已处理错误并更新 state
    }
  }

  /// 更新输入文本
  void updateInput(String input) {
    state = state.copyWith(input: input);
  }

  // ── 内部辅助方法 ──

  /// 在消息列表末��添加空 assistant 占位消息
  void _appendPlaceholder() {
    final msg = InterviewMessage(
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  /// 更新最后一条消息内容
  void _updateLastMessage(String content) {
    final updated = List<InterviewMessage>.from(state.messages);
    updated[updated.length - 1] = updated.last.copyWith(content: content);
    state = state.copyWith(messages: updated);
  }

  /// 移除末尾空消息
  void _removeEmptyLastMessage() {
    if (state.messages.isNotEmpty && state.messages.last.content.isEmpty) {
      state = state.copyWith(
        messages: state.messages.sublist(0, state.messages.length - 1),
      );
    }
  }

  Future<void> _cancelActiveStream() async {
    final sub = _streamSub;
    _streamSub = null;
    await sub?.cancel();
  }

  /// 持久化 assistant 消息
  Future<void> _persistAssistant(ChatDao chatDao, String content) async {
    try {
      await _persistMessage(chatDao, 'assistant', content);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: '保存采访记录失败: $e');
    }
  }

  /// 持久化消息到数据库
  Future<void> _persistMessage(
    ChatDao chatDao,
    String role,
    String content,
  ) {
    return chatDao
        .insertMessage(db.ChatMessagesCompanion(
          conversationId: Value(_conversationId),
          role: Value(role),
          content: Value(content),
          sessionId: Value(_sessionId),
          summaryType: const Value('interview'),
          createdAt: Value(DateTime.now()),
        ))
        .timeout(_databaseTimeout);
  }

  /// 构建发送给 LLM 的完整消息列表
  Future<List<llm_models.ChatMessage>> _buildPromptMessages(
    List<InterviewMessage> chatHistory,
  ) async {
    final sessionDao = _ref.read(runSessionDaoProvider);
    final session = await sessionDao.getSessionById(_sessionId);
    if (session == null) {
      return [
        const llm_models.ChatMessage(
          role: llm_models.ChatRole.system,
          content: '你是一名热情的跑步观众，正在赛后采访跑者。',
        ),
      ];
    }

    // 构建跑者画像 — 只取最近 50 条已完成记录，避免全表加载
    final recentSessions = await sessionDao.getRecentCompleted(limit: 50);
    final profile = RunnerProfileBuilder.build(recentSessions);

    // 查询本场喊话
    final shoutDao = _ref.read(audienceShoutDaoProvider);
    final shouts = filterShoutsForSpeaker(
      await shoutDao.getBySession(_sessionId),
      _role,
      _personality,
    );

    // 组装 prompt（根据当前语言选择中/英文）
    final locale = _ref.read(localeProvider);
    final lang = locale?.languageCode ?? 'zh';
    final promptData = InterviewPromptBuilder.build(
      role: _role,
      personality: _personality,
      profile: profile,
      session: session,
      shouts: shouts,
      chatHistory:
          chatHistory.map((m) => {'role': m.role, 'content': m.content}).toList(),
      lang: lang,
    );

    return promptData.map((m) {
      final role = switch (m['role']) {
        'user' => llm_models.ChatRole.user,
        'assistant' => llm_models.ChatRole.assistant,
        _ => llm_models.ChatRole.system,
      };
      return llm_models.ChatMessage(
        role: role,
        content: m['content'] ?? '',
      );
    }).toList();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
