// LLM 数据模型定义

/// 消息角色
enum ChatRole { system, user, assistant }

/// 聊天消息
class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime? timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  ChatMessage copyWith({
    ChatRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'content': content,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRole.values.firstWhere((e) => e.name == json['role']),
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

/// LLM 请求配置
class LlmConfig {
  final String? model;
  final double temperature;
  final int maxTokens;
  final double? topP;

  const LlmConfig({
    this.model,
    this.temperature = 0.7,
    this.maxTokens = 1024,
    this.topP,
  });
}

/// 预设 LLM 厂商
enum LlmPreset {
  openai,
  claude,
  qianwen,
  zhipu,
  minimax,
  openclaw,
  custom,
}

/// LLM 厂商显示名
extension LlmPresetLabel on LlmPreset {
  String get displayName {
    switch (this) {
      case LlmPreset.openai:
        return 'OpenAI';
      case LlmPreset.claude:
        return 'Claude (Anthropic)';
      case LlmPreset.qianwen:
        return '通义千问';
      case LlmPreset.zhipu:
        return '智谱 GLM';
      case LlmPreset.minimax:
        return 'MiniMax';
      case LlmPreset.openclaw:
        return 'OpenClaw';
      case LlmPreset.custom:
        return '自定义';
    }
  }
}

/// LLM 提供者配置
class LlmProviderConfig {
  final LlmPreset preset;
  final String baseUrl;
  final String apiKey;
  final String model;
  final Map<String, String> extraHeaders;

  const LlmProviderConfig({
    required this.preset,
    required this.baseUrl,
    this.apiKey = '',
    this.model = '',
    this.extraHeaders = const {},
  });

  LlmProviderConfig copyWith({
    LlmPreset? preset,
    String? baseUrl,
    String? apiKey,
    String? model,
    Map<String, String>? extraHeaders,
  }) {
    return LlmProviderConfig(
      preset: preset ?? this.preset,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      extraHeaders: extraHeaders ?? this.extraHeaders,
    );
  }

  /// 序列化时不包含 apiKey，防止意外泄露
  Map<String, dynamic> toJson() => {
    'preset': preset.name,
    'baseUrl': baseUrl,
    'model': model,
    'extraHeaders': extraHeaders,
  };

  factory LlmProviderConfig.fromJson(Map<String, dynamic> json) {
    return LlmProviderConfig(
      preset: LlmPreset.values.firstWhere((e) => e.name == json['preset']),
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? '',
      extraHeaders: (json['extraHeaders'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)) ?? {},
    );
  }
}

/// LLM 调用异常
class LlmException implements Exception {
  final String message;
  final int? statusCode;

  const LlmException(this.message, {this.statusCode});

  @override
  String toString() => 'LlmException($statusCode): $message';
}

class LlmAuthException extends LlmException {
  const LlmAuthException(super.message) : super(statusCode: 401);
}

class LlmRateLimitException extends LlmException {
  const LlmRateLimitException(super.message) : super(statusCode: 429);
}

class LlmNetworkException extends LlmException {
  const LlmNetworkException(super.message);
}
