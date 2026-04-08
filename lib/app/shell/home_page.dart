import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/rp_animations.dart';
import '../../shared/widgets/rp_components.dart';
import '../../shared/widgets/rp_skeleton.dart';
import '../theme.dart';

/// 首页（问候语 + 本周汇总 + 快速开始 + 训练入口）
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 6) return S.of(context)!.home_greetingNight;
    if (hour < 12) return S.of(context)!.home_greetingMorning;
    if (hour < 18) return S.of(context)!.home_greetingAfternoon;
    return S.of(context)!.home_greetingEvening;
  }

  String _dateString(BuildContext context) {
    final now = DateTime.now();
    final weekday = S.of(context)!.home_weekdays(now.weekday.toString());
    return S.of(context)!.home_dateFormat(now.month, now.day, weekday);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekSessionsProvider);
    final nicknameAsync = ref.watch(nicknameProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 品牌标识（小号 muted）
              Text('RUNPURE', style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: 12,
                color: context.rpMuted, letterSpacing: 4,
              )),
              const SizedBox(height: 8),
              // 问候语
              nicknameAsync.when(
                loading: () => Text(_greeting(context), style: TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 36,
                  color: context.rpText, letterSpacing: 2,
                )),
                error: (_, _) => Text(_greeting(context), style: TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 36,
                  color: context.rpText, letterSpacing: 2,
                )),
                data: (nickname) => Text(
                  nickname.isNotEmpty
                      ? S.of(context)!.home_greetingWithName(_greeting(context), nickname)
                      : _greeting(context),
                  style: TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 36,
                    color: context.rpText, letterSpacing: 2,
                  ),
                ),
              ),
              Text(_dateString(context), style: TextStyle(
                fontSize: 13, color: context.rpMuted,
              )),
              const SizedBox(height: 24),

              // 本周汇总卡片
              weekAsync.when(
                loading: () => const RpCardSkeleton(height: 80),
                error: (e, s) => const SizedBox.shrink(),
                data: (sessions) => _buildWeekCard(context, sessions),
              ),
              const SizedBox(height: 12),

              // 训练计划入口
              RpTapScale(
                onTap: () => context.push('/training'),
                child: RpCard(
                  tier: RpCardTier.tier2,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Text('\u26A1', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context)!.home_trainingPlan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(S.of(context)!.home_trainingPlanSubtitle, style: TextStyle(fontSize: 11, color: context.rpMuted)),
                        ],
                      )),
                      Icon(Icons.chevron_right, color: context.rpMuted, size: 20),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              // 开始跑步按钮（带脉冲光环）
              Center(child: StartButton(onTap: () => context.push('/tracking'))),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCard(BuildContext context, List<RunSession> sessions) {
    final distKm = sessions.fold<double>(0, (sum, s) => sum + s.distanceMeters) / 1000;
    final count = sessions.length;
    final avgPace = sessions.isNotEmpty
        ? (sessions.fold<int>(0, (sum, s) => sum + s.avgPaceSecPerKm) / sessions.length).round()
        : 0;
    final pMin = avgPace ~/ 60;
    final pSec = avgPace % 60;

    return RpCard(
      tier: RpCardTier.tier3,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context)!.home_thisWeek, style: TextStyle(fontSize: 10, color: context.rpMuted, letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat(context, distKm.toStringAsFixed(1), S.of(context)!.home_unitKm),
              Container(width: 1, height: 30, color: context.rpBorder),
              _stat(context, '$count', S.of(context)!.home_unitTimes),
              Container(width: 1, height: 30, color: context.rpBorder),
              _stat(context, avgPace > 0 ? '$pMin\'${pSec.toString().padLeft(2, '0')}"' : '--', S.of(context)!.home_avgPace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String unit) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 24)),
      Text(unit, style: TextStyle(fontSize: 10, color: context.rpMuted)),
    ]));
  }
}

/// 开始跑步按钮 — 带脉冲光环动画
class StartButton extends StatefulWidget {
  final VoidCallback onTap;
  const StartButton({super.key, required this.onTap});

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseScale = Tween(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 脉冲光环
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Opacity(
              opacity: _pulseOpacity.value,
              child: Transform.scale(
                scale: _pulseScale.value,
                child: Container(
                  width: 128, height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SolrunColors.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 主按钮
          RpTapScale(
            haptic: false,
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            },
            child: Container(
              width: 128, height: 128,
              decoration: BoxDecoration(
                color: SolrunColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SolrunColors.accent.withValues(alpha: 0.4),
                    blurRadius: 30, spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, color: Color(0xFF0A0A0F), size: 40),
                  Text(S.of(context)!.home_startRun, style: const TextStyle(
                    fontFamily: 'DMSans', color: Color(0xFF0A0A0F),
                    fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页本周跑步数据 provider
final weekSessionsProvider = FutureProvider<List<RunSession>>((ref) {
  return ref.read(runSessionDaoProvider).getSessionsThisWeek();
});

/// 用户昵称 provider
final nicknameProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('nickname') ?? '';
});
