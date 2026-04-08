import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/audience_roles.dart';
import '../interview_state.dart';

/// 采访消息气泡
class InterviewMessageBubble extends StatelessWidget {
  final InterviewMessage message;
  final AudienceRole role;
  final bool isStreaming;

  const InterviewMessageBubble({
    super.key,
    required this.message,
    required this.role,
    this.isStreaming = false,
  });

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            _RoleAvatar(emoji: role.emoji),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isUser
                    ? context.rpAccent.withValues(alpha: 0.15)
                    : context.rpCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(_isUser ? 14 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 14),
                ),
                border: Border.all(
                  color: _isUser
                      ? context.rpAccent.withValues(alpha: 0.3)
                      : context.rpBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content.isEmpty && isStreaming
                        ? s.audience_interviewStreaming
                        : message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.rpText,
                      height: 1.5,
                    ),
                  ),
                  if (isStreaming && message.content.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: _TypingIndicator(),
                    ),
                ],
              ),
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            const _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

/// 角色头像
class _RoleAvatar extends StatelessWidget {
  final String emoji;

  const _RoleAvatar({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.rpCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// 用户头像
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.rpAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.person, size: 18, color: context.rpAccent),
    );
  }
}

/// 打字指示器 — 三个跳动的圆点
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final progress = (_ctrl.value - i * 0.15) % 1.0;
            final scale = (progress < 0.3)
                ? 0.5 + progress / 0.3 * 0.5
                : 1.0 - ((progress - 0.3) / 0.7) * 0.5;
            return Container(
              margin: const EdgeInsets.only(right: 3),
              width: 5 * scale,
              height: 5 * scale,
              decoration: BoxDecoration(
                color: context.rpAccent.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
