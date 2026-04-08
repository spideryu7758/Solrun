import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../domain/share_card_config.dart';

/// 比例选择器 — 胶囊按钮
class AspectRatioSelector extends StatelessWidget {
  final CardAspectRatio selected;
  final ValueChanged<CardAspectRatio> onChanged;

  const AspectRatioSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CardAspectRatio.values.map((r) {
        final isSelected = r == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(r);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? SolrunColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? SolrunColors.accent : Colors.white24,
                ),
              ),
              child: Text(r.label, style: TextStyle(
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
                color: isSelected ? const Color(0xFF0A0A0F) : Colors.white60,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }
}
