import 'llm_models.dart';

/// LLM 提供者抽象接口
abstract class LlmProvider {
  /// 单次完成请求
  Future<String> complete(
    List<ChatMessage> messages, {
    LlmConfig? config,
  });

  /// 流式完成请求（SSE），逐 token 返回
  Stream<String> completeStream(
    List<ChatMessage> messages, {
    LlmConfig? config,
  });

  /// 测试连接是否可用
  Future<bool> testConnection();

  /// 释放资源
  void dispose();
}
