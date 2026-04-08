/// 赛后采访单条消息
class InterviewMessage {
  /// 'user' / 'assistant'
  final String role;

  /// 消息内容
  final String content;

  /// 创建时间
  final DateTime createdAt;

  const InterviewMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  InterviewMessage copyWith({String? content}) {
    return InterviewMessage(
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}

/// 赛后采访状态
class InterviewState {
  /// 对话消息列表
  final List<InterviewMessage> messages;

  /// 当前输入文本
  final String input;

  /// 是否正在流式生成
  final bool isStreaming;

  /// 错误信息（null 表示无错误)
  final String? error;

  const InterviewState({
    this.messages = const [],
    this.input = '',
    this.isStreaming = false,
    this.error,
  });

  /// 哨兵对象，用于区分「未传 error 参数」与「显式传 null 清除错误」
  static const Object _sentinel = Object();

  InterviewState copyWith({
    List<InterviewMessage>? messages,
    String? input,
    bool? isStreaming,
    Object? error = _sentinel,
  }) {
    return InterviewState(
      messages: messages ?? this.messages,
      input: input ?? this.input,
      isStreaming: isStreaming ?? this.isStreaming,
      // 未传 error 时保留原值；显式传 null 清除错误；传字符串设置新错误
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}
