import '../llm_http_client.dart';
import '../llm_models.dart';
import '../llm_provider.dart';

/// Anthropic Claude 原生 Messages API Provider
class AnthropicProvider implements LlmProvider {
  final LlmProviderConfig config;
  final LlmHttpClient _client = LlmHttpClient();

  AnthropicProvider(this.config);

  String get _messagesUrl {
    final base = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;
    return '$base/v1/messages';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': config.apiKey,
    'anthropic-version': '2024-10-22',
    ...config.extraHeaders,
  };

  Map<String, dynamic> _buildBody(
    List<ChatMessage> messages, {
    LlmConfig? llmConfig,
    bool stream = false,
  }) {
    // Anthropic 格式：system 单独提取，其余为 user/assistant 交替
    String? systemPrompt;
    final apiMessages = <Map<String, dynamic>>[];

    for (final msg in messages) {
      if (msg.role == ChatRole.system) {
        systemPrompt = msg.content;
      } else {
        apiMessages.add({
          'role': msg.role.name,
          'content': msg.content,
        });
      }
    }

    final model = llmConfig?.model ?? config.model;
    final body = <String, dynamic>{
      'model': model.isNotEmpty ? model : 'claude-sonnet-4-20250514',
      'messages': apiMessages,
      'max_tokens': llmConfig?.maxTokens ?? 1024,
      'stream': stream,
    };

    if (systemPrompt != null) {
      body['system'] = systemPrompt;
    }
    if (llmConfig != null) {
      body['temperature'] = llmConfig.temperature;
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
      url: _messagesUrl,
      body: _buildBody(messages, llmConfig: config),
      headers: _headers,
    );

    // Anthropic 响应格式: content[0].text
    final content = response['content'] as List;
    if (content.isEmpty) throw const LlmException('未返回任何结果');
    return (content[0] as Map<String, dynamic>)['text'] as String? ?? '';
  }

  @override
  Stream<String> completeStream(
    List<ChatMessage> messages, {
    LlmConfig? config,
  }) {
    // Anthropic SSE 事件流，_extractToken 已支持 delta.text 格式
    return _client.postStream(
      url: _messagesUrl,
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
