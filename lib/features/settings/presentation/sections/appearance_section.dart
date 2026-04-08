import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/locale_provider.dart';
import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/theme_provider.dart';
import '../../../../shared/widgets/rp_components.dart';
import '../../../../shared/widgets/rp_animations.dart';

/// 外观区域：主题选择 + 语言选择
class AppearanceSection extends ConsumerStatefulWidget {
  const AppearanceSection({super.key});

  @override
  ConsumerState<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends ConsumerState<AppearanceSection> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          ThemeMode.values[prefs.getInt('theme_mode') ?? 2]; // 默认 dark
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 外观
        RpSectionHeader(S.of(context)!.settings_appearance),
        _buildThemeTile(),

        // 语言
        RpSectionHeader(S.of(context)!.settings_language),
        _buildLanguageTile(),
      ],
    );
  }

  // --------------- 主题 ---------------

  Widget _buildThemeTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _themeOption(Icons.dark_mode,
              S.of(context)!.settings_themeDark, ThemeMode.dark),
          const SizedBox(width: 8),
          _themeOption(Icons.light_mode,
              S.of(context)!.settings_themeLight, ThemeMode.light),
          const SizedBox(width: 8),
          _themeOption(Icons.phone_android,
              S.of(context)!.settings_themeSystem, ThemeMode.system),
        ],
      ),
    );
  }

  Widget _themeOption(IconData icon, String label, ThemeMode mode) {
    final isSelected = _themeMode == mode;
    return Expanded(
      child: RpTapScale(
        onTap: () {
          setState(() => _themeMode = mode);
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.rpAccent.withValues(alpha: 0.1)
                : context.rpCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? context.rpAccent : context.rpBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 24,
                  color:
                      isSelected ? context.rpAccent : context.rpMuted),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? context.rpAccent
                        : context.rpMuted,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // --------------- 语言 ---------------

  Widget _buildLanguageTile() {
    final currentMode = ref.watch(localeProvider.notifier).currentMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _languageOption('中', S.of(context)!.settings_langZh,
              LocaleMode.zh, currentMode),
          const SizedBox(width: 8),
          _languageOption('En', S.of(context)!.settings_langEn,
              LocaleMode.en, currentMode),
          const SizedBox(width: 8),
          _languageOption(
              '\u{1F4F1}',
              S.of(context)!.settings_langSystem,
              LocaleMode.system,
              currentMode),
        ],
      ),
    );
  }

  Widget _languageOption(
      String icon, String label, LocaleMode mode, LocaleMode current) {
    final isSelected = current == mode;
    return Expanded(
      child: RpTapScale(
        onTap: () => ref.read(localeProvider.notifier).setMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.rpAccent.withValues(alpha: 0.1)
                : context.rpCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? context.rpAccent : context.rpBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isSelected
                        ? context.rpAccent
                        : context.rpMuted,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? context.rpAccent
                        : context.rpMuted,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
