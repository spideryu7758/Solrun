import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/share_card_config.dart';

/// 模板选择器 — 水平滚动缩略图
class TemplateSelector extends StatelessWidget {
  final CardTemplate selected;
  final ValueChanged<CardTemplate> onChanged;

  const TemplateSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: CardTemplate.values.map((t) => _buildItem(context, t)).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, CardTemplate template) {
    final isSelected = template == selected;
    final s = S.of(context)!;
    final label = switch (template) {
      CardTemplate.classic  => s.share_templateClassic,
      CardTemplate.heatmap  => s.share_templateHeatmap,
      CardTemplate.mapPhoto => s.share_templateMap,
      CardTemplate.minimal  => s.share_templateMinimal,
    };
    final icon = switch (template) {
      CardTemplate.classic  => Icons.crop_portrait,
      CardTemplate.heatmap  => Icons.gradient,
      CardTemplate.mapPhoto => Icons.map_outlined,
      CardTemplate.minimal  => Icons.minimize,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(template);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          decoration: BoxDecoration(
            color: isSelected ? SolrunColors.accent.withValues(alpha: 0.15) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? SolrunColors.accent : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20,
                  color: isSelected ? SolrunColors.accent : Colors.white60),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                fontSize: 11,
                color: isSelected ? SolrunColors.accent : Colors.white60,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
