import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/rp_animations.dart';

/// 采访页底部输入栏
class InterviewInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onChanged;
  final VoidCallback onStop;

  const InterviewInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
    required this.onChanged,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: context.rpSurface,
        border: Border(top: BorderSide(color: context.rpBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(fontSize: 14, color: context.rpText),
                decoration: InputDecoration(
                  hintText: s.audience_interviewHint,
                  hintStyle: TextStyle(color: context.rpMuted),
                  filled: true,
                  fillColor: context.rpCard,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: context.rpAccent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isStreaming) {
      return RpTapScale(
        onTap: onStop,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.rpDanger.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.stop, color: context.rpDanger, size: 20),
        ),
      );
    }
    return RpTapScale(
      onTap: () => onSend(controller.text),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.rpAccent,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send, color: Color(0xFF0A0A0F), size: 18),
      ),
    );
  }
}
