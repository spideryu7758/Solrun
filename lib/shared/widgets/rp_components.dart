import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'rp_animations.dart';

// ---------------------------------------------------------------------------
// RpCard — 通用卡片容器，三级视觉层次
// ---------------------------------------------------------------------------

enum RpCardTier {
  /// 背景级：rpCard 填充 + rpBorder 边框（设置行、次要信息）
  tier1,

  /// 标准级：+微阴影（数据卡片、交互卡片）
  tier2,

  /// 强调级：+左侧 accent 色条 + 微渐变背景（汇总、记录、成就）
  tier3,
}

class RpCard extends StatelessWidget {
  final Widget child;
  final RpCardTier tier;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  /// 可选：覆盖默认背景色
  final Color? color;

  /// 可选：覆盖默认边框色
  final Color? borderColor;

  const RpCard({
    super.key,
    required this.child,
    this.tier = RpCardTier.tier1,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 12,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.rpCard;
    final border = borderColor ?? context.rpBorder;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // tier3 左侧 accent 色条
    // 使用 ClipRRect 裁剪 + 内部渐变背景，无需额外嵌套 Container 做圆角
    if (tier == RpCardTier.tier3) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.rpAccent.withValues(alpha: 0.06),
                  bg,
                ],
              ),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                // 左侧 accent 色条
                Container(
                  width: 3,
                  constraints: const BoxConstraints(minHeight: 40),
                  color: context.rpAccent,
                ),
                Expanded(
                  child: Padding(padding: padding, child: child),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border),
        boxShadow: tier == RpCardTier.tier2
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// RpMetric — 数值 + 标签列
// ---------------------------------------------------------------------------

class RpMetric extends StatelessWidget {
  final String value;
  final String label;

  /// 数值颜色（默认 rpText）
  final Color? valueColor;

  /// 是否使用 BebasNeue 大字体（默认 JetBrainsMono）
  final bool useBebas;
  final double valueFontSize;
  final double labelFontSize;

  const RpMetric({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.useBebas = false,
    this.valueFontSize = 18,
    this.labelFontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: useBebas ? 'BebasNeue' : 'JetBrainsMono',
            fontSize: valueFontSize,
            fontWeight: useBebas ? FontWeight.normal : FontWeight.w600,
            color: valueColor ?? context.rpText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: context.rpMuted,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RpSectionHeader — 分区标题
// ---------------------------------------------------------------------------

class RpSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const RpSectionHeader(
    this.title, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          color: context.rpMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RpEmptyState — 空状态占位
// ---------------------------------------------------------------------------

class RpEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const RpEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: context.rpMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: context.rpMuted),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: context.rpMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              RpTapScale(
                // onTap 留空，仅由 ElevatedButton.onPressed 触发，避免双重回调
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolrunColors.accent,
                    foregroundColor: const Color(0xFF0A0A0F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RpDialog — 统一对话框样式
// ---------------------------------------------------------------------------

class RpDialog {
  /// 显示确认对话框，返回 true/false
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = '取消',
    String confirmText = '确认',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.rpCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: context.rpText, fontSize: 17)),
        content: Text(content, style: TextStyle(color: context.rpMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText, style: TextStyle(color: context.rpMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(color: confirmColor ?? context.rpAccent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示信息对话框（仅一个确认按钮）
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = '确定',
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.rpCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: context.rpText, fontSize: 17)),
        content: Text(content, style: TextStyle(color: context.rpMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(buttonText, style: TextStyle(color: context.rpAccent)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RpSnackBar — 统一浮动圆角 Snackbar
// ---------------------------------------------------------------------------

class RpSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: context.rpText)),
        backgroundColor: context.rpSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
