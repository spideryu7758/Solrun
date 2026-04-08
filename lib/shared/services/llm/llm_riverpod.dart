import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/ai_settings/data/ai_preferences.dart';
import 'llm_models.dart';
import 'llm_provider.dart';
import 'llm_registry.dart';

/// 当前激活的 LLM 配置
final llmConfigProvider = FutureProvider<LlmProviderConfig?>((ref) async {
  return AiPreferences.loadConfig();
});

/// 当前激活的 LLM 实例
final activeLlmProvider = Provider<LlmProvider?>((ref) {
  final configAsync = ref.watch(llmConfigProvider);
  final config = configAsync.valueOrNull;
  if (config == null || config.baseUrl.isEmpty) return null;

  final provider = LlmRegistry.create(config);
  ref.onDispose(() => provider.dispose());
  return provider;
});

/// AI 功能是否可用（已配置有效的 Provider）
final aiAvailableProvider = Provider<bool>((ref) {
  return ref.watch(activeLlmProvider) != null;
});
