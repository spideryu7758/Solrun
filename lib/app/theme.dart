import 'package:flutter/material.dart';

/// Solrun 设计系统 token，与 DESIGN.md 一一对应
class SolrunColors {
  // 深色主题
  static const darkBg = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF12121A);
  static const darkCard = Color(0xFF1A1A26);
  static const darkBorder = Color(0xFF2A2A3A);
  static const darkText = Color(0xFFF0F0F8);
  static const darkMuted = Color(0xFF8888A8);

  // 浅色主题
  static const lightBg = Color(0xFFF5F5FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFEEEEF4);
  static const lightBorder = Color(0xFFD8D8E4);
  static const lightText = Color(0xFF1A1A26);
  static const lightMuted = Color(0xFF8888A0);

  // 深色主题强调色
  static const accent = Color(0xFFE8FF47);
  static const accent2 = Color(0xFF47C8FF);

  // 浅色主题强调色（深色版本，确保在白色背景上可读）
  static const lightAccent = Color(0xFF7A8B00);
  static const lightAccent2 = Color(0xFF0088CC);

  static const danger = Color(0xFFFF4757);

  // 渐变预设
  static const accentGradient = LinearGradient(
    colors: [accent, accent2],
  );
}

/// AppBar 标题统一样式
const rpAppBarTitleStyle = TextStyle(
  fontFamily: 'BebasNeue',
  fontSize: 28,
  letterSpacing: 3,
);

/// Theme-aware 颜色扩展 — 替代硬编码 SolrunColors.dark*
extension SolrunThemeColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get rpBg => _isDark ? SolrunColors.darkBg : SolrunColors.lightBg;
  Color get rpSurface => _isDark ? SolrunColors.darkSurface : SolrunColors.lightSurface;
  Color get rpCard => _isDark ? SolrunColors.darkCard : SolrunColors.lightCard;
  Color get rpBorder => _isDark ? SolrunColors.darkBorder : SolrunColors.lightBorder;
  Color get rpText => _isDark ? SolrunColors.darkText : SolrunColors.lightText;
  Color get rpMuted => _isDark ? SolrunColors.darkMuted : SolrunColors.lightMuted;
  Color get rpAccent => _isDark ? SolrunColors.accent : SolrunColors.lightAccent;
  Color get rpAccent2 => _isDark ? SolrunColors.accent2 : SolrunColors.lightAccent2;
  Color get rpDanger => SolrunColors.danger;
  // 开始按钮等大面积 accent 元素，两个主题都用荧光黄
  Color get rpAccentButton => SolrunColors.accent;
}

class SolrunTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SolrunColors.darkBg,
      colorScheme: const ColorScheme.dark(
        surface: SolrunColors.darkSurface,
        primary: SolrunColors.accent,
        secondary: SolrunColors.accent2,
        error: SolrunColors.danger,
        onPrimary: SolrunColors.darkBg,
        onSurface: SolrunColors.darkText,
      ),
      cardColor: SolrunColors.darkCard,
      dividerColor: SolrunColors.darkBorder,
      fontFamily: 'DMSans',
      textTheme: _buildTextTheme(SolrunColors.darkText, SolrunColors.darkMuted),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SolrunColors.darkSurface,
        selectedItemColor: SolrunColors.accent,
        unselectedItemColor: SolrunColors.darkMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SolrunColors.darkBg,
        foregroundColor: SolrunColors.darkText,
        elevation: 0,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: SolrunColors.lightBg,
      colorScheme: const ColorScheme.light(
        surface: SolrunColors.lightSurface,
        primary: SolrunColors.lightAccent,
        secondary: SolrunColors.lightAccent2,
        error: SolrunColors.danger,
        onPrimary: SolrunColors.lightSurface,
        onSurface: SolrunColors.lightText,
      ),
      cardColor: SolrunColors.lightCard,
      dividerColor: SolrunColors.lightBorder,
      fontFamily: 'DMSans',
      textTheme: _buildTextTheme(SolrunColors.lightText, SolrunColors.lightMuted),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SolrunColors.lightSurface,
        selectedItemColor: SolrunColors.lightAccent,
        unselectedItemColor: SolrunColors.lightMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SolrunColors.lightBg,
        foregroundColor: SolrunColors.lightText,
        elevation: 0,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      // 数据大字 — Bebas Neue
      displayLarge: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 72,
        color: textColor,
        letterSpacing: 2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 48,
        color: textColor,
        letterSpacing: 2,
      ),
      displaySmall: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 28,
        color: textColor,
        letterSpacing: 3,
      ),
      // 正文 — DM Sans
      bodyLarge: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      // 标签 — DM Sans
      labelLarge: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 1,
      ),
      labelSmall: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: mutedColor,
        letterSpacing: 2,
      ),
      // 数值 — JetBrains Mono
      titleLarge: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }
}
