import 'dart:collection';

/// 累计爬升计算器
///
/// GPS 海拔噪声大（手机误差 ±10-20m），直接累加相邻点差值会严重高估。
/// 策略：
/// 1. 滑动窗口中位数滤波（去除尖刺噪声）
/// 2. 最小爬升阈值（忽略 < 2m 的微小波动）
/// 3. 只在确认趋势变化时才累加（防止震荡）
class ElevationCalculator {
  /// 滑动窗口大小（用于中位数滤波）
  static const int _windowSize = 5;

  /// 最小爬升阈值（米），低于此值视为噪声
  static const double _minGainThreshold = 2.0;

  final _rawWindow = Queue<double>();
  double? _lastConfirmedAlt; // 上一个确认的海拔（滤波后）
  double _pendingGain = 0; // 待确认的累积爬升
  double _pendingLoss = 0; // 待确认的累积下降
  double _totalGain = 0;

  /// 累计爬升（米）
  double get totalGainMeters => _totalGain;

  /// 添加一个海拔采样点
  void addAltitude(double? altitude) {
    if (altitude == null) return;

    _rawWindow.addLast(altitude);
    if (_rawWindow.length > _windowSize) {
      _rawWindow.removeFirst();
    }

    // 窗口未满时不计算
    if (_rawWindow.length < _windowSize) return;

    // 中位数滤波
    final sorted = _rawWindow.toList()..sort();
    final median = sorted[_windowSize ~/ 2];

    if (_lastConfirmedAlt == null) {
      _lastConfirmedAlt = median;
      return;
    }

    final diff = median - _lastConfirmedAlt!;

    if (diff > 0) {
      // 上升趋势
      _pendingGain += diff;
      // 如果之前有累积下降，说明趋势反转了，重置下降
      if (_pendingLoss > 0) _pendingLoss = 0;
    } else if (diff < 0) {
      // 下降趋势
      _pendingLoss += diff.abs();
      // 如果之前有累积上升且超过阈值，确认这段爬升
      if (_pendingGain >= _minGainThreshold) {
        _totalGain += _pendingGain;
      }
      _pendingGain = 0;
    }

    _lastConfirmedAlt = median;
  }

  /// 结束时，把最后一段待确认的爬升也算上
  void finish() {
    if (_pendingGain >= _minGainThreshold) {
      _totalGain += _pendingGain;
      _pendingGain = 0;
    }
  }

  /// 重置
  void reset() {
    _rawWindow.clear();
    _lastConfirmedAlt = null;
    _pendingGain = 0;
    _pendingLoss = 0;
    _totalGain = 0;
  }
}
