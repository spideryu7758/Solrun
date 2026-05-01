import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/llm/llm_models.dart';
import '../../../shared/services/llm/llm_registry.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../data/ai_preferences.dart';

/// AI 服务配置页面
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  LlmPreset _selectedPreset = LlmPreset.openai;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _obscureKey = true;
  bool _testing = false;
  bool? _testResult;
  String? _testError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await AiPreferences.loadConfig();
    if (config != null && mounted) {
      setState(() {
        _selectedPreset = config.preset;
        _apiKeyController.text = config.apiKey;
        _baseUrlController.text = config.baseUrl;
        _modelController.text = config.model;
      });
    } else {
      // 加载默认预设
      _applyPreset(_selectedPreset);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyPreset(LlmPreset preset) {
    final defaults = LlmRegistry.presets[preset]!;
    setState(() {
      _selectedPreset = preset;
      _testResult = null;
    });
    AiPreferences.loadConfigFor(preset).then((config) {
      if (!mounted || _selectedPreset != preset) return;
      setState(() {
        _apiKeyController.text = config.apiKey;
        _baseUrlController.text = config.baseUrl.isNotEmpty
            ? config.baseUrl
            : defaults.baseUrl;
        _modelController.text = config.model.isNotEmpty
            ? config.model
            : defaults.model;
      });
    });
  }

  Future<void> _saveConfig() async {
    final config = LlmProviderConfig(
      preset: _selectedPreset,
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
    );
    await AiPreferences.saveConfig(config);
    await AiPreferences.setEnabled(true);
    // 刷新 Riverpod provider
    ref.invalidate(llmConfigProvider);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context)!.aiSettings_saved)));
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final config = LlmProviderConfig(
      preset: _selectedPreset,
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
    );
    final provider = LlmRegistry.create(config);
    debugPrint(
      '[AiSettings] testConnection start '
      'preset=${config.preset.name} '
      'provider=${provider.runtimeType} '
      'baseUrl=${config.baseUrl} '
      'model=${config.model.isEmpty ? "<empty>" : config.model} '
      'hasApiKey=${config.apiKey.isNotEmpty}',
    );

    try {
      final success = await provider.testConnection();
      debugPrint('[AiSettings] testConnection success result=$success');
      if (mounted) {
        setState(() {
          _testResult = success;
          _testError = null;
        });
      }
    } catch (e) {
      debugPrint(
        '[AiSettings] testConnection failed '
        'type=${e.runtimeType} '
        'message=$e',
      );
      if (mounted) {
        setState(() {
          _testResult = false;
          _testError = '$e';
        });
      }
    } finally {
      debugPrint('[AiSettings] testConnection done');
      provider.dispose();
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _clearConfig() async {
    await AiPreferences.clearConfig();
    await AiPreferences.setEnabled(false);
    ref.invalidate(llmConfigProvider);
    _apiKeyController.clear();
    _applyPreset(LlmPreset.openai);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.aiSettings_cleared)),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context)!.aiSettings_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context)!.aiSettings_title,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            letterSpacing: 3,
            color: Theme.of(context).textTheme.displaySmall?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: S.of(context)!.aiSettings_clearConfig,
            onPressed: _clearConfig,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 厂商选择
          _sectionHeader(S.of(context)!.aiSettings_provider),
          const SizedBox(height: 8),
          _buildPresetSelector(),
          const SizedBox(height: 24),

          // API Key
          _sectionHeader('API Key'),
          const SizedBox(height: 8),
          _buildApiKeyField(),
          const SizedBox(height: 16),

          // 服务地址
          _sectionHeader(S.of(context)!.aiSettings_baseUrl),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _baseUrlController,
            hint: 'https://api.example.com/v1',
            icon: Icons.link,
          ),
          const SizedBox(height: 16),

          // 模型
          _sectionHeader(S.of(context)!.aiSettings_model),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _modelController,
            hint: S.of(context)!.aiSettings_modelHint,
            icon: Icons.memory,
          ),
          const SizedBox(height: 32),

          // 测试连接
          _buildTestButton(),
          const SizedBox(height: 12),

          // 保存
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.rpAccent,
                foregroundColor: const Color(0xFF0A0A0F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context)!.aiSettings_save,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 说明文字
          _buildHelpText(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        color: context.rpMuted,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPresetSelector() {
    final presets = LlmPreset.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final selected = _selectedPreset == preset;
        return ChoiceChip(
          label: Text(preset.displayName),
          selected: selected,
          onSelected: (_) => _applyPreset(preset),
          selectedColor: context.rpAccent,
          backgroundColor: context.rpCard,
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0A0A0F) : context.rpText,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? context.rpAccent : context.rpBorder,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiKeyField() {
    return TextField(
      controller: _apiKeyController,
      obscureText: _obscureKey,
      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
      decoration: InputDecoration(
        hintText: S.of(context)!.aiSettings_apiKeyHint,
        prefixIcon: const Icon(Icons.key, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureKey ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureKey = !_obscureKey),
        ),
        filled: true,
        fillColor: context.rpCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpAccent),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: context.rpCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.rpAccent),
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _testResult == null
                ? const Icon(Icons.wifi_tethering, size: 18)
                : Icon(
                    _testResult! ? Icons.check_circle : Icons.error,
                    size: 18,
                    color: _testResult! ? Colors.green : context.rpDanger,
                  ),
            label: Text(
              _testing
                  ? S.of(context)!.aiSettings_testing
                  : _testResult == null
                  ? S.of(context)!.aiSettings_testConnection
                  : _testResult!
                  ? S.of(context)!.aiSettings_testSuccess
                  : S.of(context)!.aiSettings_testFail,
              style: TextStyle(fontSize: 14, color: context.rpText),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: context.rpBorder),
            ),
          ),
        ),
        // 失败时显示错误详情
        if (_testError != null && _testResult == false)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.rpDanger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.rpDanger.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                _testError!,
                style: TextStyle(
                  fontSize: 12,
                  color: context.rpDanger,
                  height: 1.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.rpCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rpBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context)!.aiSettings_helpTitle,
            style: TextStyle(
              fontSize: 13,
              color: context.rpText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _helpLine(S.of(context)!.aiSettings_help1),
          _helpLine(S.of(context)!.aiSettings_help2),
          _helpLine(S.of(context)!.aiSettings_help3),
          _helpLine(S.of(context)!.aiSettings_help4),
        ],
      ),
    );
  }

  Widget _helpLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('· ', style: TextStyle(color: context.rpMuted, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: context.rpMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
