import '../llm_http_client.dart';
import '../llm_models.dart';
import '../llm_provider.dart';

/// OpenAI 兼容协议 Provider
/// 覆盖: OpenAI / 通义千问 / 智谱 / MiniMax / OpenClaw / 自定义
class OpenAiCompatibleProvider implements LlmProvider {
  final LlmProviderConfig config;
  final LlmHttpClient _client = LlmHttpClient();

  OpenAiCompatibleProvider(this.config);

  String get _chatUrl {
    final base = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;
    return '$base/chat/completions';
  }

  Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json',
      ...config.extraHeaders,
    };
    if (config.apiKey.isNotEmpty) {
      h['Authorization'] = 'Bearer ${config.apiKey}';
    }
    return h;
  }

  Map<String, dynamic> _buildBody(
    List<ChatMessage> messages, {
    LlmConfig? llmConfig,
    bool stream = false,
  }) {
    final body = <String, dynamic>{
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };

    final model = llmConfig?.model ?? config.model;
    if (model.isNotEmpty) {
      body['model'] = model;
    }

    if (llmConfig != null) {
      body['temperature'] = llmConfig.temperature;
      body['max_tokens'] = llmConfig.maxTokens;
      if (llmConfig.topP != null) {
        body['top_p'] = llmConfig.topP;
      }
    }

    return body;
  }

  @override
  Future<String> complete(
    List<ChatMessage> messages, {
    LlmConfig? config,
  }) async {
    final response = await _client.post(
      url: _chatUrl,
      body: _buildBody(messages, llmConfig: config),
      headers: _headers,
    );

    final choices = response['choices'] as List;
    if (choices.isEmpty) throw const LlmException('未返回任何结果');
    final choice = choices[0] as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;
    return message['content'] as String? ?? '';
  }

  @override
  Stream<String> completeStream(
    List<ChatMessage> messages, {
    LlmConfig? config,
  }) {
    return _client.postStream(
      url: _chatUrl,
      body: _buildBody(messages, llmConfig: config, stream: true),
      headers: _headers,
    );
  }

  /// 测试连接，失败时抛出异常（含错误详情）
  @override
  Future<bool> testConnection() async {
    final testMessages = [
      const ChatMessage(role: ChatRole.user, content: 'Hi'),
    ];
    await complete(
      testMessages,
      config: const LlmConfig(maxTokens: 5, temperature: 0),
    );
    return true;
  }

  @override
  void dispose() {
    _client.dispose();
  }
}
