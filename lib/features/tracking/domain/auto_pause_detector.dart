/// 自动暂停检测器
/// - 速度 < 1.0 km/h 持续 5 秒 → 触发暂停
/// - 速度 > 1.5 km/h → 恢复
/// - 使用迟滞（hysteresis）避免临界值震荡
class AutoPauseDetector {
  /// 暂停触发速度阈值（m/s）。1.0 km/h ≈ 0.278 m/s
  static const double pauseSpeedThreshold = 0.278;

  /// 恢复速度阈值（m/s）。1.5 km/h ≈ 0.417 m/s
  static const double resumeSpeedThreshold = 0.417;

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
  AutoPauseEvent? update(double speedMs, DateTime timestamp) {
    if (_isPaused) {
      // 当前已暂停，检查是否应恢复
      if (speedMs > resumeSpeedThreshold) {
        _isPaused = false;
        _slowSince = null;
        return AutoPauseEvent.resumed;
      }
    } else {
      // 当前正在运动，检查是否应暂停
      if (speedMs < pauseSpeedThreshold) {
        _slowSince ??= timestamp;
        final slowDuration = timestamp.difference(_slowSince!).inSeconds;
        if (slowDuration >= pauseDelaySec) {
          _isPaused = true;
          return AutoPauseEvent.paused;
        }
      } else {
        // 速度恢复到暂停阈值以上，重置计时
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
