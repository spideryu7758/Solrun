import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/audience_engine.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';

/// 跑步中弹幕浮层
/// 从顶部滑入（200ms）→ 停留 4 秒 → 淡出（300ms）
class ShoutOverlay extends StatefulWidget {
  final ShoutResult shout;
  final VoidCallback? onFavorite;
  final VoidCallback? onDismissed;

  const ShoutOverlay({
    super.key,
    required this.shout,
    this.onFavorite,
    this.onDismissed,
  });

  @override
  State<ShoutOverlay> createState() => _ShoutOverlayState();
}

class _ShoutOverlayState extends State<ShoutOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isFavorite = false;
  bool _isSubmittingFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4300),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.93),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.07),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final role = widget.shout.role;
    final personality = widget.shout.personality;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.047, curve: Curves.easeOut),
        )),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.rpSurface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.rpAccent.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 角色 emoji
                Text(role.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 角色名×人格名
                      Text(
                        '${role.localizedName(s)}·${personality.localizedName(s)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.rpMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 喊话内容
                      Text(
                        widget.shout.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.rpText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 收藏按钮
                GestureDetector(
                  onTap: _isFavorite || _isSubmittingFavorite
                      ? null
                      : () async {
                          setState(() {
                            _isSubmittingFavorite = true;
                            _isFavorite = true;
                          });
                          try {
                            widget.onFavorite?.call();
                          } catch (_) {
                            // 收藏写入失败，回滚乐观更新
                            if (mounted) {
                              setState(() {
                                _isFavorite = false;
                                _isSubmittingFavorite = false;
                              });
                            }
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _isFavorite ? Colors.redAccent : context.rpMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
