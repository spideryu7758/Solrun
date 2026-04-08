import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/llm/llm_riverpod.dart';
import '../../../../shared/widgets/rp_components.dart';

/// 跑步设置区域：自动暂停 + 语音播报 + AI 助手入口
class RunSettingsSection extends ConsumerStatefulWidget {
  const RunSettingsSection({super.key});

  @override
  ConsumerState<RunSettingsSection> createState() =>
      _RunSettingsSectionState();
}

class _RunSettingsSectionState extends ConsumerState<RunSettingsSection> {
  bool _autoPause = false;
  bool _ttsEnabled = true;
  int _ttsIntervalKm = 1;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoPause = prefs.getBool('auto_pause') ?? false;
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
      _ttsIntervalKm = prefs.getInt('tts_interval_km') ?? 1;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  String _aiConfigSubtitle(BuildContext context) {
    final isAvailable = ref.watch(aiAvailableProvider);
    return isAvailable
        ? S.of(context)!.settings_aiConfigured
        : S.of(context)!.settings_aiNotConfigured;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 跑步设置
        RpSectionHeader(S.of(context)!.settings_runSettings),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildSwitchTile(
                S.of(context)!.settings_autoPause,
                S.of(context)!.settings_autoPauseDesc,
                _autoPause,
                (v) {
                  setState(() => _autoPause = v);
                  _savePref('auto_pause', v);
                },
              ),
            ]),
          ),
        ),

        // 语音播报
        RpSectionHeader(S.of(context)!.settings_ttsSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildSwitchTile(
                S.of(context)!.settings_tts,
                S.of(context)!.settings_ttsDesc,
                _ttsEnabled,
                (v) {
                  setState(() => _ttsEnabled = v);
                  _savePref('tts_enabled', v);
                },
              ),
              if (_ttsEnabled) _buildTtsIntervalTile(),
            ]),
          ),
        ),

        // AI 助手
        RpSectionHeader(S.of(context)!.settings_aiSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildActionTile(
                S.of(context)!.settings_aiConfig,
                _aiConfigSubtitle(context),
                Icons.smart_toy,
                () => context.push('/ai-settings'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // --------------- 通用构建方法 ---------------

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      value: value,
      activeTrackColor: SolrunColors.accent,
      onChanged: onChanged,
    );
  }

  Widget _buildTtsIntervalTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_ttsInterval),
      trailing: DropdownButton<int>(
        value: _ttsIntervalKm,
        dropdownColor: context.rpCard,
        items: [
          DropdownMenuItem(
              value: 1,
              child: Text(S.of(context)!.settings_ttsEveryKm(1))),
          DropdownMenuItem(
              value: 2,
              child: Text(S.of(context)!.settings_ttsEveryKm(2))),
          DropdownMenuItem(
              value: 5,
              child: Text(S.of(context)!.settings_ttsEveryKm(5))),
        ],
        onChanged: (v) {
          if (v != null) {
            setState(() => _ttsIntervalKm = v);
            _savePref('tts_interval_km', v);
          }
        },
      ),
    );
  }

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.rpText),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      onTap: onTap,
    );
  }
}
