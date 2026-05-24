/// 自动暂停检测器
/// - 有步频传感器时：低步频 + GPS 未明确移动 → 触发暂停
/// - 无步频传感器时：低速或小位移持续 3 秒 → 触发暂停
/// - 恢复时步频或 GPS 任一明确移动持续确认后恢复
/// - 使用迟滞（hysteresis）避免临界值震荡
class AutoPauseDetector {
  /// 暂停触发速度阈值（m/s）。1.0 km/h ≈ 0.278 m/s
  static const double pauseSpeedThreshold = 0.278;

  /// 恢复速度阈值（m/s）。约 2.9 km/h，避免原地晃动触发恢复。
  static const double resumeSpeedThreshold = 0.8;

  /// 最近 GPS 位移低于该阈值时可认为近似停止。
  static const double pauseDisplacementThresholdMeters = 4.0;

  /// 最近 GPS 位移高于该阈值时可认为恢复移动。
  static const double resumeDisplacementThresholdMeters = 10.0;

  /// GPS 位移恢复判断窗口（秒）。
  static const int resumeDisplacementWindowSec = 6;

  /// 最近位移窗口的平均速度也要达到该值，避免大漂移误恢复。
  static const double resumeAverageSpeedThreshold = 0.8;

  /// 精度差于该值时不信任小位移暂停判断，只使用速度。
  static const double maxAccuracyForDisplacementMeters = 20.0;

  /// 低于该步频视为停止或近似停止。
  static const int pauseCadenceThresholdSpm = 10;

  /// 高于该步频视为已恢复跑动/步行。
  static const int resumeCadenceThresholdSpm = 40;

  /// 需要持续低于阈值的时间（秒）
  static const int pauseDelaySec = 3;

  /// 需要持续高于恢复阈值的时间（秒）
  static const int resumeDelaySec = 3;

  /// 自动暂停刚触发后的最小保持时间（秒），防止 GPS 漂移立刻恢复。
  static const int minPauseHoldSec = 2;

  bool _isPaused = false;
  DateTime? _slowSince; // 低运动状态首次出现的时间
  DateTime? _resumeSince; // 恢复运动状态首次出现的时间
  DateTime? _pausedAt; // 自动暂停确认时间

  /// 当前是否处于自动暂停状态
  bool get isPaused => _isPaused;

  /// 是否正在等待暂停确认。
  bool get isPausePending => !_isPaused && _slowSince != null;

  /// 当前候选暂停段的推断起点。
  DateTime? get pendingPauseStartedAt => isPausePending ? _slowSince : null;

  /// 是否正在等待恢复确认。
  bool get isResumePending => _isPaused && _resumeSince != null;

  /// 当前候选恢复段的推断起点。
  DateTime? get pendingResumeStartedAt => isResumePending ? _resumeSince : null;

  /// 更新速度，返回状态变化事件
  /// - [AutoPauseEvent.paused]：刚触发暂停
  /// - [AutoPauseEvent.resumed]：刚恢复
  /// - null：状态未变
  AutoPauseUpdate? update(
    double speedMs,
    DateTime timestamp, {
    int? cadenceSpm,
    DateTime? lowMotionStartedAt,
    DateTime? highMotionStartedAt,
    double? recentDisplacementMeters,
    Duration? recentDisplacementDuration,
    double? accuracyMeters,
  }) {
    final hasReliableDisplacement =
        recentDisplacementMeters != null &&
        (accuracyMeters == null ||
            accuracyMeters <= maxAccuracyForDisplacementMeters);
    final lowSpeed = speedMs < pauseSpeedThreshold;
    final lowDisplacement =
        hasReliableDisplacement &&
        recentDisplacementMeters <= pauseDisplacementThresholdMeters;
    final lowGpsMotion = lowSpeed || lowDisplacement;
    final resumedByDisplacement =
        hasReliableDisplacement &&
        recentDisplacementDuration != null &&
        recentDisplacementDuration > Duration.zero &&
        recentDisplacementMeters >= resumeDisplacementThresholdMeters &&
        recentDisplacementMeters /
                recentDisplacementDuration.inMilliseconds *
                1000 >=
            resumeAverageSpeedThreshold;
    final resumedGpsMotion =
        speedMs > resumeSpeedThreshold || resumedByDisplacement;

    final lowCadence =
        cadenceSpm != null && cadenceSpm < pauseCadenceThresholdSpm;
    final resumedCadence =
        cadenceSpm != null && cadenceSpm >= resumeCadenceThresholdSpm;

    final shouldPause = cadenceSpm != null
        ? lowCadence && !resumedGpsMotion
        : lowGpsMotion;
    final shouldResume = resumedCadence || resumedGpsMotion;

    if (_isPaused) {
      // 当前已暂停，检查是否应恢复
      if (shouldResume) {
        final inferredResumeSince = _inferHighMotionStart(
          timestamp: timestamp,
          highMotionStartedAt: highMotionStartedAt,
        );
        if (_resumeSince == null ||
            inferredResumeSince.isBefore(_resumeSince!)) {
          _resumeSince = inferredResumeSince;
        }
        final underMinHold =
            !resumedCadence &&
            _pausedAt != null &&
            timestamp.difference(_pausedAt!).inSeconds < minPauseHoldSec;
        final resumeDuration = timestamp.difference(_resumeSince!).inSeconds;
        if (!underMinHold && resumeDuration >= resumeDelaySec) {
          final effectiveAt = _resumeSince!;
          _isPaused = false;
          _slowSince = null;
          _resumeSince = null;
          _pausedAt = null;
          return AutoPauseUpdate.resumed(effectiveAt);
        }
      } else {
        _resumeSince = null;
      }
    } else {
      // 当前正在运动，检查是否应暂停
      if (shouldPause) {
        final inferredSlowSince = _inferLowMotionStart(
          timestamp: timestamp,
          lowDisplacement: lowDisplacement,
          recentDisplacementDuration: recentDisplacementDuration,
          lowMotionStartedAt: lowMotionStartedAt,
        );
        if (_slowSince == null || inferredSlowSince.isBefore(_slowSince!)) {
          _slowSince = inferredSlowSince;
        }
        final slowDuration = timestamp.difference(_slowSince!).inSeconds;
        if (slowDuration >= pauseDelaySec) {
          _isPaused = true;
          _resumeSince = null;
          _pausedAt = timestamp;
          return AutoPauseUpdate.paused(_slowSince!);
        }
      } else {
        // GPS 明确移动或步频恢复时，重置低运动计时。
        _slowSince = null;
        _resumeSince = null;
      }
    }
    return null;
  }

  /// 重置检测器
  void reset() {
    _isPaused = false;
    _slowSince = null;
    _resumeSince = null;
    _pausedAt = null;
  }

  DateTime _inferLowMotionStart({
    required DateTime timestamp,
    required bool lowDisplacement,
    required Duration? recentDisplacementDuration,
    required DateTime? lowMotionStartedAt,
  }) {
    var inferred = timestamp;
    if (lowDisplacement && recentDisplacementDuration != null) {
      inferred = timestamp.subtract(recentDisplacementDuration);
    }
    if (lowMotionStartedAt != null && lowMotionStartedAt.isBefore(inferred)) {
      inferred = lowMotionStartedAt;
    }
    if (inferred.isAfter(timestamp)) return timestamp;
    return inferred;
  }

  DateTime _inferHighMotionStart({
    required DateTime timestamp,
    required DateTime? highMotionStartedAt,
  }) {
    var inferred = timestamp;
    if (highMotionStartedAt != null && highMotionStartedAt.isBefore(inferred)) {
      inferred = highMotionStartedAt;
    }
    if (_pausedAt != null && inferred.isBefore(_pausedAt!)) {
      inferred = _pausedAt!;
    }
    if (inferred.isAfter(timestamp)) return timestamp;
    return inferred;
  }
}

enum AutoPauseEvent { paused, resumed }

class AutoPauseUpdate {
  final AutoPauseEvent event;

  /// 状态变化的有效生效时间。
  ///
  /// 暂停事件会回溯到低运动状态的起点；恢复事件会回溯到恢复候选起点。
  final DateTime effectiveAt;

  const AutoPauseUpdate._({required this.event, required this.effectiveAt});

  const AutoPauseUpdate.paused(DateTime effectiveAt)
    : this._(event: AutoPauseEvent.paused, effectiveAt: effectiveAt);

  const AutoPauseUpdate.resumed(DateTime effectiveAt)
    : this._(event: AutoPauseEvent.resumed, effectiveAt: effectiveAt);
}
