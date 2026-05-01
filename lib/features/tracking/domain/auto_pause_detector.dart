/// 自动暂停检测器
/// - 有步频传感器时：低步频 + GPS 未明确移动 → 触发暂停
/// - 无步频传感器时：低速或小位移持续 5 秒 → 触发暂停
/// - 恢复时步频或 GPS 任一明确移动即可恢复
/// - 使用迟滞（hysteresis）避免临界值震荡
class AutoPauseDetector {
  /// 暂停触发速度阈值（m/s）。1.0 km/h ≈ 0.278 m/s
  static const double pauseSpeedThreshold = 0.278;

  /// 恢复速度阈值（m/s）。1.5 km/h ≈ 0.417 m/s
  static const double resumeSpeedThreshold = 0.417;

  /// 最近 GPS 位移低于该阈值时可认为近似停止。
  static const double pauseDisplacementThresholdMeters = 4.0;

  /// 最近 GPS 位移高于该阈值时可认为恢复移动。
  static const double resumeDisplacementThresholdMeters = 8.0;

  /// 精度差于该值时不信任小位移暂停判断，只使用速度。
  static const double maxAccuracyForDisplacementMeters = 20.0;

  /// 低于该步频视为停止或近似停止。
  static const int pauseCadenceThresholdSpm = 10;

  /// 高于该步频视为已恢复跑动/步行。
  static const int resumeCadenceThresholdSpm = 20;

  /// 需要持续低于阈值的时间（秒）
  static const int pauseDelaySec = 5;

  bool _isPaused = false;
  DateTime? _slowSince; // 速度首次低于阈值的时间

  /// 当前是否处于自动暂停状态
  bool get isPaused => _isPaused;

  /// 更新速度，返回状态变化事件
  /// - [AutoPauseEvent.paused]：刚触发暂停
  /// - [AutoPauseEvent.resumed]：刚恢复
  /// - null：状态未变
  AutoPauseEvent? update(
    double speedMs,
    DateTime timestamp, {
    int? cadenceSpm,
    double? recentDisplacementMeters,
    double? accuracyMeters,
  }) {
    final hasReliableDisplacement =
        recentDisplacementMeters != null &&
        (accuracyMeters == null ||
            accuracyMeters <= maxAccuracyForDisplacementMeters);
    final lowGpsMotion =
        speedMs < pauseSpeedThreshold ||
        (hasReliableDisplacement &&
            recentDisplacementMeters <= pauseDisplacementThresholdMeters);
    final resumedGpsMotion =
        speedMs > resumeSpeedThreshold ||
        (hasReliableDisplacement &&
            recentDisplacementMeters >= resumeDisplacementThresholdMeters);

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
        _isPaused = false;
        _slowSince = null;
        return AutoPauseEvent.resumed;
      }
    } else {
      // 当前正在运动，检查是否应暂停
      if (shouldPause) {
        _slowSince ??= timestamp;
        final slowDuration = timestamp.difference(_slowSince!).inSeconds;
        if (slowDuration >= pauseDelaySec) {
          _isPaused = true;
          return AutoPauseEvent.paused;
        }
      } else {
        // GPS 明确移动或步频恢复时，重置低运动计时。
        _slowSince = null;
      }
    }
    return null;
  }

  /// 重置检测器
  void reset() {
    _isPaused = false;
    _slowSince = null;
  }
}

enum AutoPauseEvent { paused, resumed }
