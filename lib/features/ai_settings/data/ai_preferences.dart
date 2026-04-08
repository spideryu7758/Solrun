import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/llm/llm_models.dart';

/// AI 偏好设置存储
/// API Key 使用 flutter_secure_storage 加密存储
/// 其他配置使用 SharedPreferences
class AiPreferences {
  static const _secureStorage = FlutterSecureStorage();

  // SharedPreferences 键名
  static const _keyPreset = 'ai_preset';
  static const _legacyKeyBaseUrl = 'ai_base_url';
  static const _legacyKeyModel = 'ai_model';
  static const _keyBaseUrlPrefix = 'ai_base_url_';
  static const _keyModelPrefix = 'ai_model_';
  static const _keyEnabled = 'ai_enabled';

  // SecureStorage 键名前缀（按厂商分别存储 API Key）
  static const _keyApiKeyPrefix = 'ai_api_key_';

  /// 获取指定 preset 的 API Key 存储键名
  static String _apiKeyFor(LlmPreset preset) => '$_keyApiKeyPrefix${preset.name}';
  static String _baseUrlFor(LlmPreset preset) => '$_keyBaseUrlPrefix${preset.name}';
  static String _modelFor(LlmPreset preset) => '$_keyModelPrefix${preset.name}';

  /// 读取当前激活的 LLM 配置
  static Future<LlmProviderConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final presetName = prefs.getString(_keyPreset);
    if (presetName == null) return null;

    final preset = LlmPreset.values.firstWhere(
      (e) => e.name == presetName,
      orElse: () => LlmPreset.custom,
    );

    final config = await loadConfigFor(preset);
    if (config.baseUrl.isNotEmpty || config.model.isNotEmpty) {
      return config;
    }

    final apiKey = await _secureStorage.read(key: _apiKeyFor(preset)) ?? '';
    final legacyBaseUrl = prefs.getString(_legacyKeyBaseUrl) ?? '';
    final legacyModel = prefs.getString(_legacyKeyModel) ?? '';
    if (legacyBaseUrl.isNotEmpty || legacyModel.isNotEmpty) {
      final migrated = LlmProviderConfig(
        preset: preset,
        baseUrl: legacyBaseUrl,
        apiKey: apiKey,
        model: legacyModel,
      );
      await _migrateLegacyConfig(prefs, migrated);
      return migrated;
    }

    return LlmProviderConfig(
      preset: preset,
      baseUrl: '',
      apiKey: apiKey,
      model: '',
    );
  }

  /// 读取指定 preset 的 API Key（切换厂商时回显）
  static Future<String> loadApiKeyFor(LlmPreset preset) async {
    return await _secureStorage.read(key: _apiKeyFor(preset)) ?? '';
  }

  /// 读取指定 preset 的完整配置
  static Future<LlmProviderConfig> loadConfigFor(LlmPreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _secureStorage.read(key: _apiKeyFor(preset)) ?? '';
    final baseUrl = prefs.getString(_baseUrlFor(preset)) ?? '';
    final model = prefs.getString(_modelFor(preset)) ?? '';

    return LlmProviderConfig(
      preset: preset,
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
    );
  }

  /// 保存 LLM 配置
  static Future<void> saveConfig(LlmProviderConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreset, config.preset.name);
    await prefs.setString(_baseUrlFor(config.preset), config.baseUrl);
    await prefs.setString(_modelFor(config.preset), config.model);
    await prefs.remove(_legacyKeyBaseUrl);
    await prefs.remove(_legacyKeyModel);
    // API Key 按厂商分别存储
    await _secureStorage.write(key: _apiKeyFor(config.preset), value: config.apiKey);
  }

  /// 清除当前 LLM 配置（不清除其他厂商的 Key）
  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final presetName = prefs.getString(_keyPreset);
    await prefs.remove(_keyPreset);
    // 只清除当前厂商的 Key
    if (presetName != null) {
      final preset = LlmPreset.values.firstWhere(
        (e) => e.name == presetName,
        orElse: () => LlmPreset.custom,
      );
      await prefs.remove(_baseUrlFor(preset));
      await prefs.remove(_modelFor(preset));
      await _secureStorage.delete(key: _apiKeyFor(preset));
    }
  }

  /// 清除所有厂商的 API Key 和配置
  static Future<void> clearAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPreset);
    for (final preset in LlmPreset.values) {
      await prefs.remove(_baseUrlFor(preset));
      await prefs.remove(_modelFor(preset));
      await _secureStorage.delete(key: _apiKeyFor(preset));
    }
  }

  /// AI 功能是否已启用
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  /// 设置 AI 功能启用状态
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
  }

  static Future<void> _migrateLegacyConfig(
    SharedPreferences prefs,
    LlmProviderConfig config,
  ) async {
    await prefs.setString(_baseUrlFor(config.preset), config.baseUrl);
    await prefs.setString(_modelFor(config.preset), config.model);
    await prefs.remove(_legacyKeyBaseUrl);
    await prefs.remove(_legacyKeyModel);
  }

  /// 是否已配置 LLM（有有效的 preset）
  static Future<bool> isConfigured() async {
    final config = await loadConfig();
    return config != null && config.baseUrl.isNotEmpty;
  }
}
