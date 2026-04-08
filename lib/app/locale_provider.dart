import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言模式：中文 / 英文 / 跟随系统
enum LocaleMode { zh, en, system }

/// 语言状态管理
class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'locale_mode';

  @override
  Locale? build() {
    _load();
    return const Locale('zh'); // 默认中文
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key);
    if (index == null) return;
    final mode = LocaleMode.values[index.clamp(0, LocaleMode.values.length - 1)];
    state = _localeFor(mode);
  }

  Future<void> setMode(LocaleMode mode) async {
    state = _localeFor(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  LocaleMode get currentMode {
    if (state == null) return LocaleMode.system;
    if (state!.languageCode == 'zh') return LocaleMode.zh;
    if (state!.languageCode == 'en') return LocaleMode.en;
    return LocaleMode.system;
  }

  Locale? _localeFor(LocaleMode mode) => switch (mode) {
    LocaleMode.zh => const Locale('zh'),
    LocaleMode.en => const Locale('en'),
    LocaleMode.system => null, // null = 跟随系统
  };
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
