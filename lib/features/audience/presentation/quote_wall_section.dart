import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';
import '../providers.dart';
import 'audience_home_notifier.dart';

/// 金句墙区域 — 每页 3 条，自动轮播所有收藏
class QuoteWallSection extends ConsumerStatefulWidget {
  final AudienceHomeState data;
  const QuoteWallSection({super.key, required this.data});

  @override
  ConsumerState<QuoteWallSection> createState() => _QuoteWallSectionState();
}

class _QuoteWallSectionState extends ConsumerState<QuoteWallSection> {
  static const _pageSize = 3;
  static const _interval = Duration(seconds: 6);

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  List<List<AudienceShout>> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildPages();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(QuoteWallSection old) {
    super.didUpdateWidget(old);
    if (old.data.favorites.length != widget.data.favorites.length) {
      _buildPages();
      _currentPage = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
      _startAutoPlay();
    }
  }

  /// 将收藏列表按每 3 条分组
  void _buildPages() {
    final all = widget.data.favorites;
    _pages = [];
    for (var i = 0; i < all.length; i += _pageSize) {
      _pages.add(all.sublist(i, (i + _pageSize).clamp(0, all.length)));
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_pages.length <= 1) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % _pages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final total = widget.data.favorites.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区域标题 + 数量角标
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            children: [
              Text(
                s.audience_quoteWallTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.rpMuted,
                  letterSpacing: 2,
                ),
              ),
              if (total > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: context.rpAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$total',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.rpAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        if (_pages.isEmpty)
          RpEmptyState(
            icon: Icons.format_quote,
            title: s.audience_quoteWallEmpty,
          )
        else
          Column(
            children: [
              // 轮播区域（3 条一页）
              SizedBox(
                // 每条：RpCard padding(12*2) + 标题行(16) + 间距(3) + 内容2行(13*1.3*2) + bottom(8) ≈ 78
                // 3 条 ≈ 234，留余量取 260
                height: 260,
                child: ClipRect(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, pageIdx) {
                      final group = _pages[pageIdx];
                      return ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: group.map((shout) => _QuoteItem(
                          shout: shout,
                          onDismissed: () {
                            ref
                                .read(audienceHomeProvider.notifier)
                                .removeFavorite(shout.id, shout.isFavorite);
                            RpSnackBar.show(context, s.audience_favoriteRemoved);
                          },
                        )).toList(),
                      );
                    },
                  ),
                ),
              ),
              // 页码指示器（多页时显示）
              if (_pages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: active
                              ? context.rpAccent
                              : context.rpMuted.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// 单条金句条目（左滑取消收藏）
class _QuoteItem extends StatelessWidget {
  final AudienceShout shout;
  final VoidCallback onDismissed;

  const _QuoteItem({required this.shout, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final role = AudienceRole.fromName(shout.audienceRole);
    final personality = Personality.fromName(shout.personality);

    String scene = '';
    try {
      final ctx = jsonDecode(shout.triggerContext) as Map<String, dynamic>;
      final type = ctx['triggerType'] as String?;
      final km = ctx['currentKm'];
      if (type == 'start') {
        scene = s.audience_sceneStart;
      } else if ((type == 'split_km' || type == 'split_5km') && km != null) {
        scene = s.audience_sceneSplitKm(km);
      } else if (type == 'finish') {
        scene = s.audience_sceneFinish;
      } else if (type == 'pace_alert') {
        scene = s.audience_scenePaceAlert;
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(shout.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.heart_broken, color: Colors.red.withValues(alpha: 0.6)),
        ),
        child: RpCard(
          tier: RpCardTier.tier2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${role.localizedName(s)}·${personality.localizedName(s)}',
                          style: TextStyle(fontSize: 10, color: context.rpMuted),
                        ),
                        const Spacer(),
                        Text(
                          '${shout.createdAt.month}/${shout.createdAt.day}'
                          '${scene.isNotEmpty ? ' · $scene' : ''}',
                          style: TextStyle(
                            fontSize: 9,
                            color: context.rpMuted.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shout.content,
                      style: TextStyle(fontSize: 13, color: context.rpText, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
