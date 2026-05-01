import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/database.dart';
import '../../../data/daos/run_session_dao.dart';
import '../../../shared/services/tts_service.dart';
import '../data/location_service.dart';
import '../data/step_cadence_service.dart';
import '../data/tracking_persistence.dart';
import '../domain/auto_pause_detector.dart';
import '../domain/elevation_calculator.dart';
import '../domain/pace_calculator.dart';
import '../domain/run_finalizer.dart';
import 'tracking_state.dart';

/// 运动核心状态管理器
class TrackingNotifier extends StateNotifier<TrackingState> {
  final LocationService _locationService;
  final StepCadenceService _stepCadenceService;
  final RunSessionDao _runSessionDao;
  final TtsService _ttsService;
  final TrackingPersistence _persistence;
  final RunFinalizer _finalizer;
  final PaceCalculator _paceCalculator = PaceCalculator();
  final AutoPauseDetector _autoPauseDetector = AutoPauseDetector();
  final ElevationCalculator _elevationCalculator = ElevationCalculator();

  StreamSubscription<TrackPoint>? _gpsSub;
  StreamSubscription<CadenceSample>? _cadenceSub;
  Timer? _timer;
  Timer? _checkpointTimer;

  DateTime? _startTime;
  int _pausedDurationSec = 0;
  DateTime? _pauseStartTime;
  bool _autoPauseEnabled = false;
  double _userWeightKg = 70;
  bool _wakelockActive = false;
  bool _ttsEnabled = true;
  int _ttsIntervalKm = 1;
  int _lastAnnouncedKm = 0;
  int? _sessionId;
  bool _cadenceSensorAvailable = false;
  int? _currentCadenceSpm;
  DateTime? _lastStepAt;
  final List<TrackPoint> _autoPauseWindow = [];

  // 内存中的轨迹点缓冲（分批落库后释放）
  final List<TrackPoint> _pointBuffer = [];
  int _flushedPointCount = 0;
  int _orderIndex = 0;

  // 通知栏结束跑步的结果（供 UI 层获取后导航）
  TrackingResult? lastEndRunResult;

  /// 当前跑步的 sessionId（供观众引擎等外部模块读取）
  int? get currentSessionId => _sessionId;

  /// 当前跑步的开始时间（供观众引擎拼装上下文）
  DateTime? get currentStartTime => _startTime;

  TrackingNotifier(
    this._locationService,
    this._stepCadenceService,
    this._runSessionDao,
    this._ttsService,
    this._persistence,
    this._finalizer,
  ) : super(const TrackingState());

  /// 加载用户设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoPauseEnabled = prefs.getBool('auto_pause') ?? false;
    _userWeightKg = prefs.getDouble('weight_kg') ?? 70;
    _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    _ttsIntervalKm = prefs.getInt('tts_interval_km') ?? 1;
    _lastAnnouncedKm = 0;
    // 根据 App 语言设置 TTS 语言
    final locale = prefs.getString('locale') ?? 'zh';
    _ttsService.setLanguageTag(locale.startsWith('en') ? 'en-US' : 'zh-CN');
  }

  /// 开始跑步
  Future<void> startRun() async {
    await _loadSettings();

    // ── 防御性清理（确保上次跑步的残留资源被完全释放）──
    _timer?.cancel();
    _timer = null;
    _checkpointTimer?.cancel();
    _checkpointTimer = null;
    await _gpsSub?.cancel();
    _gpsSub = null;
    await _cadenceSub?.cancel();
    _cadenceSub = null;
    await _locationService.forceStop();
    await _stepCadenceService.stop();

    // 全量重置状态
    state = const TrackingState();
    _pausedDurationSec = 0;
    _pauseStartTime = null;
    _sessionId = null;
    lastEndRunResult = null;
    _pointBuffer.clear();
    _flushedPointCount = 0;
    _orderIndex = 0;
    _cadenceSensorAvailable = false;
    _currentCadenceSpm = null;
    _lastStepAt = null;
    _autoPauseWindow.clear();

    // 请求 GPS 权限
    final granted = await _locationService.requestPermission();
    if (!granted) {
      state = state.copyWith(
        status: TrackingStatus.idle,
        errorMessage: '无法获取完整跑步权限，请在系统设置中开启"始终允许定位"和通知权限',
      );
      return;
    }

    state = state.copyWith(status: TrackingStatus.gpsWaiting);

    // 首次请求电池优化白名单（华为/OPPO 等国产 ROM 关键）
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('battery_opt_requested') ?? false)) {
      try {
        final isIgnoring =
            await FlutterForegroundTask.isIgnoringBatteryOptimizations;
        if (!isIgnoring) {
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        }
      } catch (_) {}
      await prefs.setBool('battery_opt_requested', true);
    }

    // 启用屏幕常亮
    await WakelockPlus.enable();
    _wakelockActive = true;

    _startTime = DateTime.now();
    _paceCalculator.reset();
    _autoPauseDetector.reset();
    _elevationCalculator.reset();

    // 立即创建一条 incomplete 记录（崩溃恢复用）
    _sessionId = await _runSessionDao.insertSession(
      RunSessionsCompanion.insert(
        startTime: _startTime!,
        durationSeconds: 0,
        distanceMeters: 0,
        avgPaceSecPerKm: 0,
        bestPaceSecPerKm: 0,
        autoName: Value(_generateAutoName(_startTime!)),
      ),
    );

    // 启动 GPS 流
    await _locationService.startTracking();
    _gpsSub = _locationService.trackPointStream.listen(_onGpsPoint);

    _cadenceSensorAvailable = await _stepCadenceService.start();
    _currentCadenceSpm = _cadenceSensorAvailable ? 0 : null;
    if (_cadenceSensorAvailable) {
      _cadenceSub = _stepCadenceService.cadenceStream.listen(_onCadenceSample);
      state = state.copyWith(cadenceSpm: 0);
    }

    // 启动计时器（每秒更新）
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());

    // 启动检查点定时器（每 30 秒）
    _checkpointTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _writeCheckpoint(),
    );
  }

  void _onCadenceSample(CadenceSample sample) {
    if (!sample.available) {
      _cadenceSensorAvailable = false;
      _currentCadenceSpm = null;
      return;
    }

    _cadenceSensorAvailable = true;
    _currentCadenceSpm = sample.cadenceSpm;
    if (sample.cumulativeSteps > 0) {
      _lastStepAt = sample.timestamp;
    }
    state = state.copyWith(cadenceSpm: sample.cadenceSpm);
  }

  /// GPS 点回调
  void _onGpsPoint(TrackPoint point) {
    // 首次收到 GPS 点，从等待切换到运动
    if (state.status == TrackingStatus.gpsWaiting) {
      state = state.copyWith(status: TrackingStatus.running);
    }

    // 暂停状态下不累计距离
    if (state.status == TrackingStatus.paused) return;

    // 自动暂停检测（保持 3s 高频采样，不降频，确保恢复灵敏）
    if (_autoPauseEnabled) {
      _autoPauseWindow.add(point);
      _trimAutoPauseWindow(point.timestamp);
      final event = _autoPauseDetector.update(
        point.speed,
        point.timestamp,
        cadenceSpm: _cadenceForPause(point.timestamp),
        recentDisplacementMeters: _recentAutoPauseDisplacement(),
        accuracyMeters: point.accuracy,
      );
      if (event == AutoPauseEvent.paused) {
        _pauseStartTime = DateTime.now();
        state = state.copyWith(status: TrackingStatus.autoPaused);
        // 不降频：自动暂停期间仍以 3s 频率采样，确保恢复检测灵敏
        return;
      } else if (event == AutoPauseEvent.resumed) {
        if (_pauseStartTime != null) {
          _pausedDurationSec += DateTime.now()
              .difference(_pauseStartTime!)
              .inSeconds;
          _pauseStartTime = null;
        }
        state = state.copyWith(status: TrackingStatus.running);
      }
    }

    // 自动暂停期间不累计距离
    if (state.status == TrackingStatus.autoPaused) return;

    // 添加点到计算器
    _paceCalculator.addPoint(point);

    // 海拔累计计算（中位数滤波 + 阈值去噪）
    _elevationCalculator.addAltitude(point.altitude);

    // 缓冲轨迹点
    _pointBuffer.add(point);
    _orderIndex++;

    // 追加到检查点日志
    _persistence.appendPointToLog(point, _orderIndex);

    // 计算卡路里：体重(kg) × 距离(km) × 1.036
    final calories =
        (_userWeightKg * _paceCalculator.totalDistanceMeters / 1000 * 1.036)
            .round();

    // 更新状态
    state = state.copyWith(
      distanceMeters: _paceCalculator.totalDistanceMeters,
      currentPaceSecPerKm: _paceCalculator.currentPaceSecPerKm,
      caloriesKcal: calories,
      recentPoints: List.of(_pointBuffer),
      totalPointCount: _flushedPointCount + _pointBuffer.length,
    );

    // 语音播报检查（每 N km）
    if (_ttsEnabled && _ttsIntervalKm > 0) {
      final currentKm = (_paceCalculator.totalDistanceMeters / 1000).floor();
      final nextAnnounceKm = _lastAnnouncedKm + _ttsIntervalKm;
      if (currentKm >= nextAnnounceKm) {
        _lastAnnouncedKm = currentKm;
        _ttsService.announceStatus(
          distanceKm: _paceCalculator.totalDistanceMeters / 1000,
          paceSecPerKm: _paceCalculator.currentPaceSecPerKm,
          durationSeconds: state.durationSeconds,
        );
      }
    }

    // 分批落库检查（每 500 条）
    if (_pointBuffer.length >= 500) {
      _flushPointBuffer();
    }
  }

  /// 每秒计时
  void _onTick() {
    _refreshCadenceStaleness();
    if (state.status != TrackingStatus.running) return;
    if (_startTime == null) return;

    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    final activeDuration = elapsed - _pausedDurationSec;
    if (_pauseStartTime != null) {
      // 当前正在暂停中，不增加时间
      return;
    }

    state = state.copyWith(durationSeconds: activeDuration);
  }

  int? _cadenceForPause(DateTime now) {
    if (!_cadenceSensorAvailable) return null;
    final lastStepAt = _lastStepAt;
    if (lastStepAt == null || now.difference(lastStepAt).inSeconds > 6) {
      return 0;
    }
    if ((_currentCadenceSpm ?? 0) == 0 &&
        now.difference(lastStepAt).inSeconds <= 3) {
      return AutoPauseDetector.resumeCadenceThresholdSpm;
    }
    return _currentCadenceSpm ?? 0;
  }

  void _refreshCadenceStaleness() {
    if (!_cadenceSensorAvailable || _currentCadenceSpm == 0) return;
    final lastStepAt = _lastStepAt;
    if (lastStepAt != null &&
        DateTime.now().difference(lastStepAt).inSeconds > 6) {
      _currentCadenceSpm = 0;
      state = state.copyWith(cadenceSpm: 0);
    }
  }

  void _trimAutoPauseWindow(DateTime now) {
    final cutoff = now.subtract(const Duration(seconds: 12));
    _autoPauseWindow.removeWhere((point) => point.timestamp.isBefore(cutoff));
  }

  double? _recentAutoPauseDisplacement() {
    if (_autoPauseWindow.length < 2) return null;
    final first = _autoPauseWindow.first;
    final last = _autoPauseWindow.last;
    return Distance().as(
      LengthUnit.Meter,
      LatLng(first.latitude, first.longitude),
      LatLng(last.latitude, last.longitude),
    );
  }

  /// 手动暂停
  void pauseRun() {
    if (state.status != TrackingStatus.running) return;
    _pauseStartTime = DateTime.now();
    state = state.copyWith(status: TrackingStatus.paused);
    _locationService.updateInterval(isPaused: true);
    if (_ttsEnabled) _ttsService.announcePause(true);
  }

  /// 手动继续
  void resumeRun() {
    if (state.status != TrackingStatus.paused &&
        state.status != TrackingStatus.autoPaused) {
      return;
    }

    if (_pauseStartTime != null) {
      _pausedDurationSec += DateTime.now()
          .difference(_pauseStartTime!)
          .inSeconds;
      _pauseStartTime = null;
    }
    _autoPauseDetector.reset();
    state = state.copyWith(status: TrackingStatus.running);
    _locationService.updateInterval(isPaused: false);
    if (_ttsEnabled) _ttsService.announcePause(false);
  }

  /// 结束跑步
  Future<TrackingResult> endRun() async {
    _timer?.cancel();
    _checkpointTimer?.cancel();
    await _gpsSub?.cancel();
    await _cadenceSub?.cancel();
    _cadenceSub = null;
    await _stepCadenceService.stop();
    await _locationService.stopTracking();

    // 释放屏幕常亮
    if (_wakelockActive) {
      await WakelockPlus.disable();
      _wakelockActive = false;
    }

    // 停止原生 GPS 前台服务
    await _locationService.stopTracking();

    final endTime = DateTime.now();

    // 完成最后一个不完整公里
    _paceCalculator.finishLastSplit(endTime);

    // 完成海拔累计（把最后一段待确认的爬升算上）
    _elevationCalculator.finish();

    // 写入最后一批未满 500 条的轨迹点
    await _flushPointBuffer();

    final avgPace = state.durationSeconds > 0 && state.distanceMeters > 0
        ? (state.durationSeconds * 1000 / state.distanceMeters).round()
        : 0;
    final bestPace = _paceCalculator.splits.isNotEmpty
        ? _paceCalculator.splits
              .map((s) => s.paceSecPerKm)
              .reduce((a, b) => a < b ? a : b)
        : 0;

    // 获取语言设置
    final locale =
        (await SharedPreferences.getInstance()).getString('locale') ?? 'zh';
    final lang = locale.startsWith('en') ? 'en' : 'zh';

    // 获取城市和天气信息
    final geoWeather = await _finalizer.fetchCityAndWeather(
      sessionId: _sessionId!,
      lang: lang,
    );
    final elevationGainMeters = await _finalizer.calculateElevationGain(
      sessionId: _sessionId!,
      gpsFallbackMeters: _elevationCalculator.totalGainMeters,
    );

    // 持久化：更新 RunSession + 写入分公里配速
    if (_sessionId != null) {
      await _persistence.saveSession(
        sessionId: _sessionId!,
        startTime: _startTime!,
        endTime: endTime,
        durationSeconds: state.durationSeconds,
        distanceMeters: state.distanceMeters,
        avgPace: avgPace,
        bestPace: bestPace,
        caloriesKcal: state.caloriesKcal,
        elevationGainMeters: elevationGainMeters,
        autoName: _generateAutoName(
          _startTime!,
          city: geoWeather.city,
          lang: lang,
        ),
        city: geoWeather.city,
        weather: geoWeather.weather,
        splits: _paceCalculator.splits,
      );
    }

    // 检测成就
    if (_sessionId != null) {
      await _finalizer.checkAchievements(
        sessionId: _sessionId!,
        distanceMeters: state.distanceMeters,
        durationSeconds: state.durationSeconds,
        avgPaceSecPerKm: avgPace,
      );
    }

    // 检测观众角色解锁
    await _finalizer.checkAudienceUnlocks();

    // 清除检查点
    await _persistence.deleteCheckpoint();

    // 构建结果并赋值给 lastEndRunResult（供通知栏结束路径使用）
    // 注意：必须在设置 status: finished 之前赋值，因为 ref.listen 会立即触发
    final result = TrackingResult(
      sessionId: _sessionId,
      startTime: _startTime!,
      endTime: endTime,
      durationSeconds: state.durationSeconds,
      distanceMeters: state.distanceMeters,
      avgPaceSecPerKm: avgPace,
      bestPaceSecPerKm: bestPace,
      caloriesKcal: state.caloriesKcal,
      splits: _paceCalculator.splits,
    );
    lastEndRunResult = result;

    // 所有数据库操作完成后才设置 finished，触发 ref.listen 导航
    state = state.copyWith(status: TrackingStatus.finished);

    return result;
  }

  /// 分批落库（释放内存）
  Future<void> _flushPointBuffer() async {
    if (_pointBuffer.isEmpty || _sessionId == null) return;

    final flushed = await _persistence.flushPointBuffer(
      buffer: _pointBuffer,
      sessionId: _sessionId!,
      flushedCount: _flushedPointCount,
    );
    _flushedPointCount += flushed;
    _pointBuffer.clear();
  }

  /// 写入检查点元数据
  Future<void> _writeCheckpoint() async {
    if (_startTime == null) return;
    await _persistence.writeCheckpoint(
      startTime: _startTime!,
      durationSeconds: state.durationSeconds,
      distanceMeters: state.distanceMeters,
      splits: _paceCalculator.splits,
      flushedPointCount: _flushedPointCount,
    );
  }

  // 原生 GPS 服务独立于 Flutter 引擎管理 GPS 生命周期，
  // 不再需要心跳监测、ensureGpsStream 等恢复机制。

  /// 根据开始时间生成自动命名（支持城市前缀和中英文）
  static String _generateAutoName(
    DateTime startTime, {
    String? city,
    String lang = 'zh',
  }) {
    final hour = startTime.hour;
    final isEn = lang.startsWith('en');

    final period = isEn
        ? (hour >= 5 && hour < 9
              ? 'Dawn Run'
              : hour >= 9 && hour < 12
              ? 'Morning Run'
              : hour >= 12 && hour < 14
              ? 'Noon Run'
              : hour >= 14 && hour < 17
              ? 'Afternoon Run'
              : hour >= 17 && hour < 19
              ? 'Evening Run'
              : 'Night Run')
        : (hour >= 5 && hour < 9
              ? '清晨跑'
              : hour >= 9 && hour < 12
              ? '上午跑'
              : hour >= 12 && hour < 14
              ? '午间跑'
              : hour >= 14 && hour < 17
              ? '下午跑'
              : hour >= 17 && hour < 19
              ? '傍晚跑'
              : '夜跑');

    if (city != null && city.isNotEmpty) {
      return '$city · $period';
    }
    return period;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkpointTimer?.cancel();
    _gpsSub?.cancel();
    _cadenceSub?.cancel();
    _locationService.forceStop();
    _stepCadenceService.stop();
    if (_wakelockActive) WakelockPlus.disable();
    super.dispose();
  }
}

/// 跑步结束结果
class TrackingResult {
  final int? sessionId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final double distanceMeters;
  final int avgPaceSecPerKm;
  final int bestPaceSecPerKm;
  final int caloriesKcal;
  final List<SplitPaceData> splits;

  const TrackingResult({
    this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.avgPaceSecPerKm,
    required this.bestPaceSecPerKm,
    required this.caloriesKcal,
    required this.splits,
  });
}
