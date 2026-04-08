import 'llm_models.dart';
import 'llm_provider.dart';
import 'providers/anthropic_provider.dart';
import 'providers/openai_compatible.dart';

/// LLM 厂商预设配置表 + 工厂
class LlmRegistry {
  LlmRegistry._();

  /// 各厂商默认配置（不含 API Key）
  static const presets = <LlmPreset, LlmProviderConfig>{
    LlmPreset.openai: LlmProviderConfig(
      preset: LlmPreset.openai,
      baseUrl: 'https://api.openai.com/v1',
      model: 'gpt-4o-mini',
    ),
    LlmPreset.claude: LlmProviderConfig(
      preset: LlmPreset.claude,
      baseUrl: 'https://api.anthropic.com',
      model: 'claude-sonnet-4-20250514',
    ),
    LlmPreset.qianwen: LlmProviderConfig(
      preset: LlmPreset.qianwen,
      baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
      model: 'qwen-turbo',
    ),
    LlmPreset.zhipu: LlmProviderConfig(
      preset: LlmPreset.zhipu,
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      model: 'glm-4-flash',
    ),
    LlmPreset.minimax: LlmProviderConfig(
      preset: LlmPreset.minimax,
      baseUrl: 'https://api.minimaxi.com/v1',
      model: 'MiniMax-M2',
    ),
    LlmPreset.openclaw: LlmProviderConfig(
      preset: LlmPreset.openclaw,
      baseUrl: 'http://localhost:18789/v1',
      model: '',
    ),
    LlmPreset.custom: LlmProviderConfig(
      preset: LlmPreset.custom,
      baseUrl: '',
      model: '',
    ),
  };

  /// 根据配置创建对应的 Provider 实例
  /// Claude 走原生 Messages API，其余走 OpenAI 兼容协议
  static LlmProvider create(LlmProviderConfig config) {
    if (config.preset == LlmPreset.claude) {
      return AnthropicProvider(config);
    }
    return OpenAiCompatibleProvider(config);
  }

  /// 获取预设配置（合并用户的 apiKey/model 覆盖）
  static LlmProviderConfig getPresetConfig(
    LlmPreset preset, {
    String? apiKey,
    String? model,
    String? baseUrl,
  }) {
    final base = presets[preset]!;
    return base.copyWith(
      apiKey: apiKey,
      model: model,
      baseUrl: baseUrl,
    );
  }
}
