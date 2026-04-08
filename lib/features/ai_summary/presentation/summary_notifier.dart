import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database.dart' as db;
import '../../../data/providers.dart';
import '../../../data/run_session_status.dart';
import '../../../shared/services/llm/llm_models.dart' as llm_models;
import '../../../app/locale_provider.dart';
import '../../../shared/services/llm/llm_provider.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../domain/chat_context_builder.dart';
import '../domain/summary_prompt.dart';

/// 总结生成状态
class SummaryState {
  final String content;
  final bool isStreaming;
  final String? error;

  const SummaryState({
    this.content = '',
    this.isStreaming = false,
    this.error,
  });

  SummaryState copyWith({String? content, bool? isStreaming, String? error}) {
    return SummaryState(
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error,
    );
  }
}

/// 总结 Notifier
class SummaryNotifier extends StateNotifier<SummaryState> {
  final Ref _ref;
  StreamSubscription<String>? _streamSub;

  SummaryNotifier(this._ref) : super(const SummaryState());

  /// 生成单次跑步总结
  Future<void> generateRunSummary(int sessionId) async {
    final provider = _ref.read(activeLlmProvider);
    if (provider == null) {
      state = state.copyWith(error: '请先配置 AI 服务');
      return;
    }

    state = const SummaryState(isStreaming: true);

    try {
      // 查询跑步数据
      final session = await _ref.read(runSessionDaoProvider).getSessionById(sessionId);
      if (session == null) {
        state = state.copyWith(isStreaming: false, error: '记录不存在');
        return;
      }
      final splits = await _ref.read(splitPaceDaoProvider).getSplitsBySession(sessionId);
      final locale = _ref.read(localeProvider);
      final isEn = locale?.languageCode == 'en';
      final context = ChatContextBuilder.formatRunContext(session, splits: splits, isEn: isEn);

      await _stream(
        llmProvider: provider,
        systemPrompt: SummaryPrompt.perRunSystem(isEn: isEn),
        userMessage: SummaryPrompt.perRunUser(context, isEn: isEn),
        summaryType: 'per_run',
        sessionId: sessionId,
      );
    } catch (e) {
      state = state.copyWith(isStreaming: false, error: '$e');
    }
  }

  /// 生成周期性总结
  Future<void> generatePeriodSummary(SummaryType type) async {
    final provider = _ref.read(activeLlmProvider);
    if (provider == null) {
      state = state.copyWith(error: '请先配置 AI 服务');
      return;
    }

    state = const SummaryState(isStreaming: true);

    try {
      final sessionDao = _ref.read(runSessionDaoProvider);
      final locale = _ref.read(localeProvider);
      final isEn = locale?.languageCode == 'en';
      final now = DateTime.now();
      List<db.RunSession> sessions;
      String periodLabel;

      switch (type) {
        case SummaryType.weekly:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
          sessions = await sessionDao.getSessionsAfter(monday);
          periodLabel = isEn ? 'This Week' : '本周';
        case SummaryType.monthly:
          final monthStart = DateTime(now.year, now.month, 1);
          sessions = await sessionDao.getSessionsAfter(monthStart);
          periodLabel = isEn ? 'This Month' : '本月';
        case SummaryType.yearly:
          final yearStart = DateTime(now.year, 1, 1);
          sessions = await sessionDao.getSessionsAfter(yearStart);
          periodLabel = isEn ? 'This Year' : '本年';
        case SummaryType.perRun:
          return; // 用 generateRunSummary 替代
      }

      final completed = sessions
          .where((s) => s.status == RunSessionStatus.completed)
          .toList();
      if (completed.isEmpty) {
        state = state.copyWith(
          isStreaming: false,
          error: isEn ? 'No runs recorded for $periodLabel' : '$periodLabel暂无跑步记录',
        );
        return;
      }

      final context = ChatContextBuilder.formatMultiRunContext(completed, periodLabel, isEn: isEn);
      await _stream(
        llmProvider: provider,
        systemPrompt: SummaryPrompt.periodSystem(isEn: isEn),
        userMessage: SummaryPrompt.periodUser(context, periodLabel, isEn: isEn),
        summaryType: type.name,
      );
    } catch (e) {
      state = state.copyWith(isStreaming: false, error: '$e');
    }
  }

  /// 流式调用 LLM 并更新状态
  Future<void> _stream({
    required LlmProvider llmProvider,
    required String systemPrompt,
    required String userMessage,
    required String summaryType,
    int? sessionId,
  }) async {
    final messages = [
      llm_models.ChatMessage(role: llm_models.ChatRole.system, content: systemPrompt),
      llm_models.ChatMessage(role: llm_models.ChatRole.user, content: userMessage),
    ];

    final buffer = StringBuffer();
    final stream = llmProvider.completeStream(messages);

    _streamSub = stream.listen(
      (token) {
        if (!mounted) return;
        buffer.write(token);
        state = state.copyWith(content: buffer.toString());
      },
      onDone: () async {
        if (mounted) state = state.copyWith(isStreaming: false);
        // 持久化总结
        final dao = _ref.read(chatDaoProvider);
        final convId = const Uuid().v4();
        await dao.insertMessage(db.ChatMessagesCompanion(
          conversationId: Value(convId),
          role: const Value('assistant'),
          content: Value(buffer.toString()),
          sessionId: sessionId != null ? Value(sessionId) : const Value.absent(),
          summaryType: Value(summaryType),
          createdAt: Value(DateTime.now()),
        ));
      },
      onError: (e) {
        state = state.copyWith(
          isStreaming: false,
          error: e is llm_models.LlmException ? e.message : '$e',
        );
      },
      cancelOnError: true,
    );
  }

  void stop() {
    _streamSub?.cancel();
    _streamSub = null;
    state = state.copyWith(isStreaming: false);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
