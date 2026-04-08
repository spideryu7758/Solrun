import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/share_card_config.dart';

/// 自定义开关网格
/// 不支持当前模板的选项会置灰，点击时弹出 SnackBar 提示
class CustomizationToggles extends StatelessWidget {
  final ShareCardConfig config;
  final VoidCallback onToggleHeatmap;
  final VoidCallback onToggleMapTiles;
  final VoidCallback onTogglePaceChart;
  final VoidCallback onToggleElevation;
  final VoidCallback onToggleDataGrid;
  final VoidCallback onToggleHeader;

  const CustomizationToggles({
    super.key,
    required this.config,
    required this.onToggleHeatmap,
    required this.onToggleMapTiles,
    required this.onTogglePaceChart,
    required this.onToggleElevation,
    required this.onToggleDataGrid,
    required this.onToggleHeader,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _chip(context, s.share_toggleHeatmap, config.showHeatmap, onToggleHeatmap, ShareOption.heatmap),
        _chip(context, s.share_toggleMapTiles, config.showMapTiles, onToggleMapTiles, ShareOption.mapTiles),
        _chip(context, s.share_togglePaceChart, config.showPaceChart, onTogglePaceChart, ShareOption.paceChart),
        _chip(context, s.share_toggleElevation, config.showElevationProfile, onToggleElevation, ShareOption.elevationProfile),
        _chip(context, s.share_toggleDataGrid, config.showDataGrid, onToggleDataGrid, ShareOption.dataGrid),
        _chip(context, s.share_toggleHeader, config.showHeader, onToggleHeader, ShareOption.header),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool enabled,
    VoidCallback onTap,
    ShareOption option,
  ) {
    final supported = ShareCardConfig.isOptionSupported(
      config.template, option, aspectRatio: config.aspectRatio,
    );

    if (!supported) {
      // 不支持的选项：置灰 + 点击提示
      final s = S.of(context)!;
      final templateName = _templateLabel(context, config.template);
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.share_optionNotSupported(label, templateName)),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: SolrunColors.darkCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        child: Tooltip(
          message: S.of(context)!.share_unsupportedTemplate(_templateLabel(context, config.template)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 14,
                  color: Colors.white24,
                ),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white24,
                  decoration: TextDecoration.lineThrough,
                )),
              ],
            ),
          ),
        ),
      );
    }

    // 支持的选项：正常交互
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: enabled ? SolrunColors.accent.withValues(alpha: 0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? SolrunColors.accent.withValues(alpha: 0.5) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: enabled ? SolrunColors.accent : Colors.white38,
            ),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontSize: 11,
              color: enabled ? Colors.white : Colors.white38,
            )),
          ],
        ),
      ),
    );
  }

  /// 获取模板的本地化名称
  static String _templateLabel(BuildContext context, CardTemplate template) {
    final s = S.of(context)!;
    return switch (template) {
      CardTemplate.classic  => s.share_templateClassic,
      CardTemplate.heatmap  => s.share_templateHeatmap,
      CardTemplate.mapPhoto => s.share_templateMap,
      CardTemplate.minimal  => s.share_templateMinimal,
    };
  }
}
