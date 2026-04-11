import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/database.dart';
import '../../../data/providers.dart' show runSessionDaoProvider, splitPaceDaoProvider;
import '../../../shared/services/tts_service.dart';
import '../../tracking/presentation/tracking_state.dart';
import '../../tracking/providers.dart';
import '../providers.dart' show audienceShoutDaoProvider, audienceEngineProvider;
import '../data/audience_engine.dart';
import '../data/runner_profile_builder.dart';
import '../data/trigger_context_builder.dart';
import '../../../shared/services/weather_service.dart';
import '../domain/audience_constants.dart';
import '../domain/mood_states.dart';
import '../domain/voice_picker.dart';
import '../domain/weather_detector.dart';

/// 跑步中观众喊话状态
class AudienceShoutState {
  /// 当前显示的喊话（弹幕用）
  final ShoutResult? currentShout;

  /// 本次跑步所有喊话列表
  final List<ShoutResult> allShouts;

  /// 是否正在加载
  final bool isLoading;

  /// 选中的状态（跑前选择）
  final MoodState mood;

  /// 缓存的跑者画像（单次跑步内复用，避免每次触发全量查询）
  final RunnerProfile? cachedProfile;

  final int _lastTriggeredKm;
  final int paceAlertCount;
  final DateTime? _lastTriggerTime;

  const AudienceShoutState({
    this.currentShout,
    this.allShouts = const [],
    this.isLoading = false,
    this.mood = MoodState.motivate,
    this.cachedProfile,
    int lastTriggeredKm = 0,
    this.paceAlertCount = 0,
    DateTime? lastTriggerTime,
  })  : _lastTriggeredKm = lastTriggeredKm,
        _lastTriggerTime = lastTriggerTime;

  int get lastTriggeredKm => _lastTriggeredKm;
  DateTime? get lastTriggerTime => _lastTriggerTime;

  AudienceShoutState copyWith({
    ShoutResult? currentShout,
    bool clearShout = false,
    List<ShoutResult>? allShouts,
    bool? isLoading,
    MoodState? mood,
    RunnerProfile? cachedProfile,
    int? lastTriggeredKm,
    int? paceAlertCount,
    DateTime? lastTriggerTime,
  }) {
    return AudienceShoutState(
      currentShout: clearShout ? null : (currentShout ?? this.currentShout),
      allShouts: allShouts ?? this.allShouts,
      isLoading: isLoading ?? this.isLoading,
      mood: mood ?? this.mood,
      cachedProfile: cachedProfile ?? this.cachedProfile,
      lastTriggeredKm: lastTriggeredKm ?? _lastTriggeredKm,
      paceAlertCount: paceAlertCount ?? this.paceAlertCount,
      lastTriggerTime: lastTriggerTime ?? _lastTriggerTime,
    );
  }
}

/// 观众喊话 Notifier（零侵入：通过外部 ref.listen 监听 trackingProvider）
class AudienceShoutNotifier extends StateNotifier<AudienceShoutState> {
  final Ref _ref;
  final TtsService _tts;

  AudienceShoutNotifier(this._ref, this._tts) : super(const AudienceShoutState()) {
    _loadTtsInterval();
  }

  /// 语音播报间隔（km），与系统播报保持一致
  int _ttsIntervalKm = 1;

  /// 本次跑步的天气信息（开跑时获取一次）
  WeatherInfo? _weatherInfo;

  Future<void> _loadTtsInterval() async {
    final prefs = await SharedPreferences.getInstance();
    _ttsIntervalKm = prefs.getInt('tts_interval_km') ?? 1;
  }

  /// 设置跑前选择的今日状态
  void setMood(MoodState mood) {
    state = state.copyWith(mood: mood);
  }

  /// 重置状态（新跑步开始前调用）
  void reset() {
    VoicePicker.resetHistory();
    _weatherInfo = null;
    WeatherService.clearCache();
    state = const AudienceShoutState();
  }

  /// 清除当前弹幕显示
  void clearCurrentShout() {
    state = state.copyWith(clearShout: true);
  }

  /// 收藏喊话（跑步中弹幕仅提供单向收藏）
  Future<void> favoriteShout(int shoutId) async {
    final dao = _ref.read(audienceShoutDaoProvider);
    await dao.setFavorite(shoutId, true);
  }

  /// 跑步状态更新回调（由 providers.dart 中的 ref.listen 触发）
  void onTrackingStateUpdate(TrackingState prev, TrackingState next) {
    // ── 开跑触发（gpsWaiting → running） ──
    if (prev.status == TrackingStatus.gpsWaiting &&
        next.status == TrackingStatus.running) {
      _triggerStart(next);
    }

    // ── 距离播报同步触发（与系统语音播报使用同一间隔） ──
    if (_ttsIntervalKm > 0) {
      final prevKm = (prev.distanceMeters / 1000).floor();
      final nextKm = (next.distanceMeters / 1000).floor();
      // 检查是否跨过了播报整公里线（与 tracking_notifier 的播报逻辑一致）
      final prevAnnounce = prevKm ~/ _ttsIntervalKm;
      final nextAnnounce = nextKm ~/ _ttsIntervalKm;
      if (nextAnnounce > prevAnnounce && nextKm > 0) {
        _triggerSplitKm(nextKm, next);
      }
    }

    // ── 配速异常触发（至少跑 500m 后才开始检测，每次跑步最多 N 次） ──
    if (next.status == TrackingStatus.running &&
        next.distanceMeters >= AudienceConstants.paceAlertMinDistanceM &&
        next.currentPaceSecPerKm != null &&
        prev.currentPaceSecPerKm != null &&
        state.paceAlertCount < AudienceConstants.maxPaceAlerts) {
      final avgPace = _calcAvgPace(next);
      if (avgPace > 0 && next.currentPaceSecPerKm! > 0) {
        final deviation = (next.currentPaceSecPerKm! - avgPace).abs();
        final pct = (deviation / avgPace * 100).round();
        if (pct > AudienceConstants.paceAlertThresholdPct) {
          _triggerPaceAlert(next, avgPace);
        }
      }
    }

    // ── 结束触发 ──
    if (prev.status != TrackingStatus.finished &&
        next.status == TrackingStatus.finished) {
      _triggerFinish(next);
    }
  }

  // ── 触发方法 ──

  void _triggerStart(TrackingState ts) {
    _tryTrigger(TriggerType.start, () async {
      // 异步获取实时天气（不阻塞触发流程，失败返回 null）
      if (ts.recentPoints.isNotEmpty) {
        final pt = ts.recentPoints.last;
        try {
          final weather = await WeatherService.fetch(pt.latitude, pt.longitude);
          if (weather != null) {
            _weatherInfo = WeatherDetector.detect(DateTime.now(), weather: weather);
          }
        } catch (_) {
          // 天气获取失败不影响主流程
        }
      }
      final profile = await _getOrBuildProfile();
      final ctx = TriggerContextBuilder.buildStartContext();
      return _engineGenerate(TriggerType.start, ctx, profile);
    });
  }

  void _triggerSplitKm(int km, TrackingState ts) {
    if (km <= state.lastTriggeredKm) return;
    _tryTrigger(TriggerType.splitKm, () async {
      final profile = await _getOrBuildProfile();
      final avgPace = _calcAvgPace(ts);
      final sessionId = _getSessionId();
      final splits = sessionId != null
          ? await _ref.read(splitPaceDaoProvider).getSplitsBySession(sessionId)
          : <SplitPace>[];
      final ctx = TriggerContextBuilder.buildSplitKmContext(
        completedKm: km,
        kmPaceSecPerKm: ts.currentPaceSecPerKm ?? 0,
        avgPaceSecPerKm: avgPace,
        distanceKm: ts.distanceKm,
        durationSec: ts.durationSeconds,
        splits: splits,
        profile: profile,
      );
      state = state.copyWith(lastTriggeredKm: km);
      return _engineGenerate(TriggerType.splitKm, ctx, profile);
    });
  }

  void _triggerPaceAlert(TrackingState ts, int avgPace) {
    _tryTrigger(TriggerType.paceAlert, () async {
      final profile = await _getOrBuildProfile();
      final sessionId = _getSessionId();
      final splits = sessionId != null
          ? await _ref.read(splitPaceDaoProvider).getSplitsBySession(sessionId)
          : <SplitPace>[];
      final ctx = TriggerContextBuilder.buildPaceAlertContext(
        currentPaceSecPerKm: ts.currentPaceSecPerKm!,
        avgPaceSecPerKm: avgPace,
        distanceKm: ts.distanceKm,
        durationSec: ts.durationSeconds,
        splits: splits,
      );
      state = state.copyWith(paceAlertCount: state.paceAlertCount + 1);
      return _engineGenerate(TriggerType.paceAlert, ctx, profile);
    });
  }

  void _triggerFinish(TrackingState ts) {
    _tryTrigger(TriggerType.finish, () async {
      final profile = await _getOrBuildProfile();
      final sessionId = _getSessionId();
      final splits = sessionId != null
          ? await _ref.read(splitPaceDaoProvider).getSplitsBySession(sessionId)
          : <SplitPace>[];
      final session = sessionId != null
          ? await _ref.read(runSessionDaoProvider).getSessionById(sessionId)
          : null;
      if (session == null) return null;

      final ctx = TriggerContextBuilder.buildFinishContext(
        session: session,
        splits: splits,
        profile: profile,
      );
      return _engineGenerate(TriggerType.finish, ctx, profile);
    });
  }

  /// 冷却保护 + 互斥 + 异步执行
  void _tryTrigger(
    TriggerType type,
    Future<ShoutResult?> Function() action,
  ) {
    final now = DateTime.now();

    // 冷却检查
    if (state.lastTriggerTime != null &&
        now.difference(state.lastTriggerTime!).inSeconds <
            AudienceConstants.triggerCooldownSeconds) {
      return;
    }

    // 互斥检查
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, lastTriggerTime: now);

    // 异步执行，不阻塞状态更新回调
    _executeAction(action);
  }

  /// 执行触发动作并更新状态
  Future<void> _executeAction(Future<ShoutResult?> Function() action) async {
    try {
      final result = await action();
      if (result != null && mounted) {
        final updated = List<ShoutResult>.from(state.allShouts)..add(result);
        state = state.copyWith(
          currentShout: result,
          allShouts: updated,
          isLoading: false,
        );
        // TTS 语音播报观众喊话（优先级低于系统播报，自动排队）
        _tts.speakShout(result.content);
      } else if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<ShoutResult?> _engineGenerate(
    TriggerType triggerType,
    TriggerContext triggerContext,
    RunnerProfile profile,
  ) async {
    final sessionId = _getSessionId();
    if (sessionId == null) return null;

    // 提取本次跑步已有喊话内容，供 prompt 反重复
    final previousShouts =
        state.allShouts.map((s) => s.content).toList();

    // 使用单例引擎，保持并发互斥锁有效
    final engine = _ref.read(audienceEngineProvider);
    return engine.generateShout(
      triggerType: triggerType,
      triggerContext: triggerContext,
      profile: profile,
      mood: state.mood,
      sessionId: sessionId,
      previousShouts: previousShouts,
      startTime: _ref.read(trackingProvider.notifier).currentStartTime,
      weatherInfo: _weatherInfo,
    );
  }

  /// 获取或构建跑者画像（单次跑步内缓存复用）
  Future<RunnerProfile> _getOrBuildProfile() async {
    if (state.cachedProfile != null) return state.cachedProfile!;
    final dao = _ref.read(runSessionDaoProvider);
    // 只取最近 50 条已完成记录，避免全表加载
    final recentSessions = await dao.getRecentCompleted(limit: 50);
    final profile = RunnerProfileBuilder.build(recentSessions);
    state = state.copyWith(cachedProfile: profile);
    return profile;
  }

  int? _getSessionId() =>
      _ref.read(trackingProvider.notifier).currentSessionId;

  int _calcAvgPace(TrackingState s) {
    if (s.durationSeconds <= 0 || s.distanceMeters <= 0) return 0;
    return (s.durationSeconds * 1000 / s.distanceMeters).round();
  }
}
