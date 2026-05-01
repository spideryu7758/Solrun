import 'dart:collection';

/// 累计爬升计算器
///
/// GPS 海拔噪声大（手机误差 ±10-20m），直接累加相邻点差值会严重高估。
/// 策略：
/// 1. 滑动窗口中位数滤波（去除尖刺噪声）
/// 2. 最小爬升阈值（忽略小幅波动）
/// 3. 单点跳变过滤（忽略明显不可信的垂直跳变）
/// 4. 只在趋势反转或结束时确认爬升（防止震荡）
class ElevationCalculator {
  /// 滑动窗口大小（用于中位数滤波）
  static const int _windowSize = 7;

  /// 最小爬升阈值（米），低于此值视为噪声。
  ///
  /// 手机 GPS 垂直精度普遍差于水平精度，2m 阈值容易把平路抖动累计成虚高。
  static const double _minGainThreshold = 5.0;

  /// 单次滤波后高度跳变阈值（米）。
  ///
  /// 正常跑步 3 秒采样下，连续滤波高度跳变超过该值通常是 GPS 噪声。
  static const double _maxSingleStepChange = 25.0;

  final _rawWindow = Queue<double>();
  double? _lastConfirmedAlt; // 上一个确认的海拔（滤波后）
  double _pendingGain = 0; // 待确认的累积爬升
  double _totalGain = 0;

  /// 累计爬升（米）
  double get totalGainMeters => _totalGain;

  /// 对一组海拔值计算累计爬升。
  ///
  /// 供导入、分享卡片、在线 DEM 重算等路径复用，避免多处复制算法。
  static double calculateGain(Iterable<double?> altitudes) {
    final calculator = ElevationCalculator();
    for (final altitude in altitudes) {
      calculator.addAltitude(altitude);
    }
    calculator.finish();
    return calculator.totalGainMeters;
  }

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
    if (diff.abs() > _maxSingleStepChange) {
      _lastConfirmedAlt = median;
      _pendingGain = 0;
      return;
    }

    if (diff > 0) {
      // 上升趋势
      _pendingGain += diff;
    } else if (diff < 0) {
      // 下降趋势
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
    _totalGain = 0;
  }
}
