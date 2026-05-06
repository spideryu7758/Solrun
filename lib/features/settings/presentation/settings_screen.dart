import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'sections/appearance_section.dart';
import 'sections/data_management_section.dart';
import 'sections/map_settings_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/run_settings_section.dart';

/// 设置页面 — 组装各 section
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context)!.settings_title,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 28,
            letterSpacing: 3,
            color: Theme.of(context).textTheme.displaySmall?.color,
          ),
        ),
      ),
      body: ListView(
        children: [
          const PersonalInfoSection(),
          const RunSettingsSection(),
          const AppearanceSection(),
          const MapSettingsSection(),
          const DataManagementSection(),
          const SizedBox(height: 32),
          // 版本信息
          Center(
            child: Text(
              'Solrun v1.0.5   Powered by Haizhong',
              style: TextStyle(fontSize: 12, color: context.rpMuted),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
