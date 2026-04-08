import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// 底部导航 Shell — 自定义导航栏
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    final tabs = [
      NavTab(Icons.home_outlined, Icons.home, S.of(context)!.nav_home),
      NavTab(Icons.history_outlined, Icons.history, S.of(context)!.nav_history),
      NavTab(Icons.bar_chart_outlined, Icons.bar_chart, S.of(context)!.nav_stats),
      NavTab(Icons.stadium_outlined, Icons.stadium, S.of(context)!.nav_audience),
      NavTab(Icons.settings_outlined, Icons.settings, S.of(context)!.nav_settings),
    ];
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          // 固定 slogan — 叠在状态栏区域，不占布局空间
          Positioned(
            top: MediaQuery.of(context).padding.top - 2,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Text(
                  'No Ads \u00B7 Just Miles',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    letterSpacing: 3,
                    color: context.rpMuted.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.rpSurface,
          border: Border(top: BorderSide(color: context.rpBorder)),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isActive = i == current;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != current) {
                      HapticFeedback.selectionClick();
                      navigationShell.goBranch(i);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 选中指示条
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: isActive ? 24 : 0,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isActive ? context.rpAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: isActive ? context.rpAccent : context.rpMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? context.rpAccent : context.rpMuted,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// 底部导航 Tab 数据模型
class NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavTab(this.icon, this.activeIcon, this.label);
}
