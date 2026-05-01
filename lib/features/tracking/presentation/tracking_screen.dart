import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/map_preferences.dart';
import '../../../shared/utils/autostart_helper.dart';
import '../../../shared/utils/coord_converter.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../../../shared/widgets/rp_components.dart';
import '../../../shared/widgets/run_map.dart';
import '../../audience/presentation/mood_selector.dart';
import '../../audience/presentation/shout_overlay.dart';
import '../../audience/providers.dart'
    show
        audienceHomeProvider,
        audienceShoutProvider,
        unlockedAudienceRolesProvider,
        unlockedRolesProvider;
import '../providers.dart';
import 'tracking_state.dart';

/// 运动中页面
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final MapController _mapController = MapController();

  // ── 观众系统状态 ──
  bool _showMoodSelector = true; // 先选择状态，再倒计时
  int _countdown = 3;
  bool _countdownActive = false;

  // 平滑跟随动画
  AnimationController? _moveAnimController;
  LatLng? _lastCenter;
  DateTime _lastMoveTime = DateTime(2000);
  static const _moveThrottle = Duration(milliseconds: 500);
  static const _moveDuration = Duration(milliseconds: 300);

  // 高德地图 GCJ-02 坐标转换标记
  bool _needsGcj02 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _moveAnimController = AnimationController(
      vsync: this,
      duration: _moveDuration,
    );
    _loadGcj02Flag();
    // 不再自动开始倒计时，等用户选完状态后手动触发
  }

  Future<void> _loadGcj02Flag() async {
    final gcj02 = await MapPreferences.needsGcj02();
    if (mounted) setState(() => _needsGcj02 = gcj02);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _moveAnimController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // 原生 GPS 服务独立于 Flutter 引擎，无需手动恢复
  }

  Future<void> _startCountdown() async {
    // 倒计时期间异步检查自启动引导（不阻塞倒计时）
    AutostartHelper.showGuideIfNeeded(context);

    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _countdownActive = false);
    ref.read(trackingProvider.notifier).startRun();
  }

  @override
  Widget build(BuildContext context) {
    // 监听通知栏"结束"按钮触发的状态变化
    ref.listen<TrackingState>(trackingProvider, (prev, next) {
      if (prev?.status != TrackingStatus.finished &&
          next.status == TrackingStatus.finished) {
        ref.invalidate(unlockedRolesProvider);
        ref.invalidate(unlockedAudienceRolesProvider);
        ref.invalidate(audienceHomeProvider);
        final result = ref.read(trackingProvider.notifier).lastEndRunResult;
        if (result?.sessionId != null && mounted) {
          context.go('/tracking/result/${result!.sessionId}');
        } else if (mounted) {
          context.go('/home');
        }
      }
    });

    // ── 状态选择阶段 ──
    if (_showMoodSelector) {
      return MoodSelector(
        onSelected: (mood) {
          ref.read(audienceShoutProvider.notifier).reset();
          // 将状态传递给观众喊话引擎
          ref.read(audienceShoutProvider.notifier).setMood(mood);
          setState(() {
            _showMoodSelector = false;
            _countdownActive = true;
          });
          _startCountdown();
        },
      );
    }

    // ── 倒计时覆盖层（带脉冲动画） ──
    if (_countdownActive) {
      return Scaffold(
        backgroundColor: context.rpBg,
        body: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_countdown),
            tween: Tween(begin: 1.3, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (_, scale, child) => Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: (2.3 - scale).clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: Text(
              '$_countdown',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 120,
                color: context.rpAccent,
              ),
            ),
          ),
        ),
      );
    }

    final state = ref.watch(trackingProvider);

    final shoutState = ref.watch(audienceShoutProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.rpBg,
        body: Stack(
          children: [
            // 底层：跑步界面
            SafeArea(
              child: Column(
                children: [
                  // 地图区域
                  _buildMap(state),
                  // 数据区域
                  Expanded(child: _buildDataArea(state)),
                ],
              ),
            ),
            // 弹幕浮层
            if (shoutState.currentShout != null)
              ShoutOverlay(
                key: ValueKey(shoutState.currentShout!.shoutId),
                shout: shoutState.currentShout!,
                onFavorite: () {
                  ref
                      .read(audienceShoutProvider.notifier)
                      .favoriteShout(shoutState.currentShout!.shoutId);
                },
                onDismissed: () {
                  ref.read(audienceShoutProvider.notifier).clearCurrentShout();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(TrackingState state) {
    final center = state.recentPoints.isNotEmpty
        ? LatLng(
            state.recentPoints.last.latitude,
            state.recentPoints.last.longitude,
          )
        : const LatLng(39.9, 116.4);

    final polylinePoints = state.recentPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // 自动跟随当前位置（节流 + 平滑动画）
    if (state.recentPoints.isNotEmpty &&
        state.status == TrackingStatus.running) {
      _smoothMoveToCenter(center);
    }

    final mapHeight = MediaQuery.of(context).size.height * 0.28;

    return SizedBox(
      height: mapHeight.clamp(180, 260),
      child: Stack(
        children: [
          RunMap(
            center: center,
            polylinePoints: polylinePoints,
            showCurrentLocation: state.recentPoints.isNotEmpty,
            showStartEndMarkers: polylinePoints.length >= 2,
            controller: _mapController,
            interactive: false, // 运动中不可交互
          ),
          // 底部渐变融合
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 40,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [context.rpBg, context.rpBg.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          // 运行状态标签
          Positioned(top: 12, left: 12, child: _buildStatusBadge(state)),
        ],
      ),
    );
  }

  /// 平滑移动地图中心点（节流 500ms + Tween 插值 300ms）
  void _smoothMoveToCenter(LatLng target) {
    final now = DateTime.now();
    if (now.difference(_lastMoveTime) < _moveThrottle) return;
    _lastMoveTime = now;

    final controller = _moveAnimController;
    if (controller == null) return;

    // 高德地图需要 GCJ-02 坐标，与 RunMap 内部转换保持一致
    final convertedTarget = _needsGcj02
        ? CoordConverter.wgs84ToGcj02(target)
        : target;

    try {
      final currentZoom = _mapController.camera.zoom;
      final from = _lastCenter ?? convertedTarget;

      controller.reset();
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      );

      void listener() {
        final t = animation.value;
        final lat =
            from.latitude + (convertedTarget.latitude - from.latitude) * t;
        final lng =
            from.longitude + (convertedTarget.longitude - from.longitude) * t;
        try {
          _mapController.move(LatLng(lat, lng), currentZoom);
        } catch (_) {}
      }

      controller.addListener(listener);
      controller.forward().then((_) {
        controller.removeListener(listener);
      });

      _lastCenter = convertedTarget;
    } catch (_) {
      // mapController 可能未初始化
    }
  }

  Widget _buildStatusBadge(TrackingState state) {
    String label;
    switch (state.status) {
      case TrackingStatus.gpsWaiting:
        label = S.of(context)!.tracking_statusGpsWaiting;
      case TrackingStatus.running:
        label = S.of(context)!.tracking_statusRunning;
      case TrackingStatus.paused:
        label = S.of(context)!.tracking_statusPaused;
      case TrackingStatus.autoPaused:
        label = S.of(context)!.tracking_statusAutoPaused;
      default:
        label = '';
    }
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.rpAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.rpAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.status == TrackingStatus.running)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: RpPulse(
                minScale: 1.0,
                maxScale: 1.5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.rpAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: context.rpAccent,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataArea(TrackingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // 距离大字
          Text(
            state.distanceDisplay,
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 80,
              color: context.rpAccent,
              letterSpacing: 4,
            ),
          ),
          Text(
            S.of(context)!.tracking_unitKilometers,
            style: TextStyle(
              fontSize: 12,
              color: context.rpMuted,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),

          // 数据卡片
          Row(
            children: [
              _buildMetricCard(
                state.paceDisplay,
                S.of(context)!.tracking_labelPace,
                context.rpAccent,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                state.durationDisplay,
                S.of(context)!.tracking_labelDuration,
                context.rpText,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                state.cadenceDisplay,
                S.of(context)!.tracking_labelCadence,
                context.rpAccent2,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                '${state.caloriesKcal}',
                S.of(context)!.tracking_labelCalories,
                context.rpMuted,
              ),
            ],
          ),
          const Spacer(),

          // 控制栏
          _buildControls(state),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color valueColor) {
    return Expanded(
      child: RpCard(
        tier: RpCardTier.tier2,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: context.rpMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(TrackingState state) {
    final notifier = ref.read(trackingProvider.notifier);
    final isRunning = state.status == TrackingStatus.running;
    final isPaused =
        state.status == TrackingStatus.paused ||
        state.status == TrackingStatus.autoPaused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 暂停/继续按钮（主按钮）
        RpTapScale(
          haptic: false,
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isRunning) {
              notifier.pauseRun();
            } else if (isPaused) {
              notifier.resumeRun();
            }
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: SolrunColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SolrunColors.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: const Color(0xFF0A0A0F),
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 结束按钮
        _buildCircleButton(
          icon: Icons.stop,
          size: 52,
          onTap: () => _showStopConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return RpTapScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.rpCard,
          shape: BoxShape.circle,
          border: Border.all(color: context.rpBorder),
        ),
        child: Icon(icon, color: context.rpText, size: size * 0.45),
      ),
    );
  }

  Future<void> _showStopConfirmation(BuildContext context) async {
    final confirmed = await RpDialog.confirm(
      context,
      title: S.of(context)!.tracking_stopTitle,
      content: S.of(context)!.tracking_stopContent,
      cancelText: S.of(context)!.tracking_stopCancel,
      confirmText: S.of(context)!.tracking_stopConfirm,
    );

    if (!confirmed || !mounted) return;
    // endRun() 完成后会设置 status: finished，触发 ref.listen 统一导航
    await ref.read(trackingProvider.notifier).endRun();
  }
}
