import 'dart:collection';
import 'dart:math';

/// GPS 轨迹点数据（domain 层模型，不依赖 geolocator）
class TrackPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final double speed; // m/s
  final DateTime timestamp;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
  });
}

/// 配速计算器
/// - 实时配速：30 秒滑动窗口平均
/// - 分公里配速：每跨过整公里自动切分
class PaceCalculator {
  /// 滑动窗口大小（秒）
  static const int windowSeconds = 30;

  final _windowPoints = Queue<TrackPoint>();
  double _totalDistanceMeters = 0;
  double _currentKmDistance = 0; // 当前公里内累积距离
  DateTime? _currentKmStartTime;
  int _completedKms = 0;

  final List<SplitPaceData> _splits = [];

  /// 已完成的分公里配速列表
  List<SplitPaceData> get splits => List.unmodifiable(_splits);

  /// 累计总距离（米）
  double get totalDistanceMeters => _totalDistanceMeters;

  /// 已完成整公里数
  int get completedKms => _completedKms;

  /// GPS 断点时间阈值（秒）
  /// 正常采样 3 秒，允许偶尔延迟到 6-8 秒，超过此阈值视为流中断
  static const int _gapThresholdSeconds = 10;

  /// 添加新的轨迹点，返回该点与前一点之间的距离增量（米）
  double addPoint(TrackPoint point) {
    double deltaMeters = 0;

    if (_windowPoints.isNotEmpty) {
      final prev = _windowPoints.last;
      final timeDelta = point.timestamp.difference(prev.timestamp);

      // 断点容错：时间间隔超过阈值视为 GPS 流中断，跳过该段距离
      if (timeDelta.inSeconds > _gapThresholdSeconds) {
        _windowPoints.clear();
        _windowPoints.addLast(point);
        _currentKmStartTime ??= point.timestamp;
        return 0;
      }

      deltaMeters = _haversineDistance(
        prev.latitude,
        prev.longitude,
        point.latitude,
        point.longitude,
      );
      _totalDistanceMeters += deltaMeters;
      _currentKmDistance += deltaMeters;
    }

    // 初始化第一公里的起始时间
    _currentKmStartTime ??= point.timestamp;

    _windowPoints.addLast(point);

    // 清理超出窗口的旧点
    final cutoff = point.timestamp.subtract(
      const Duration(seconds: windowSeconds),
    );
    while (_windowPoints.isNotEmpty &&
        _windowPoints.first.timestamp.isBefore(cutoff)) {
      _windowPoints.removeFirst();
    }

    // 检查是否跨过整公里
    while (_currentKmDistance >= 1000) {
      _completedKms++;
      final overDistance = _currentKmDistance - 1000;
      // 估算到达整公里点的时间
      final kmEndTime = point.timestamp;
      final durationSec = kmEndTime.difference(_currentKmStartTime!).inSeconds;
      // 配速 = 该公里用时（秒）
      _splits.add(
        SplitPaceData(
          kmIndex: _completedKms,
          paceSecPerKm: durationSec > 0 ? durationSec : 1,
          startTime: _currentKmStartTime!,
          endTime: kmEndTime,
        ),
      );
      _currentKmStartTime = kmEndTime;
      _currentKmDistance = overDistance;
    }

    return deltaMeters;
  }

  /// 当前实时配速（秒/公里），基于 30 秒滑动窗口
  /// 返回 null 表示数据不足（窗口内不足 2 个点）
  int? get currentPaceSecPerKm {
    if (_windowPoints.length < 2) return null;

    final first = _windowPoints.first;
    final last = _windowPoints.last;
    final timeSec = last.timestamp.difference(first.timestamp).inSeconds;
    if (timeSec <= 0) return null;

    // 计算窗口内的总距离
    double windowDistance = 0;
    TrackPoint? prev;
    for (final p in _windowPoints) {
      if (prev != null) {
        windowDistance += _haversineDistance(
          prev.latitude,
          prev.longitude,
          p.latitude,
          p.longitude,
        );
      }
      prev = p;
    }

    if (windowDistance <= 0) return null;

    // 配速 = 每公里用时（秒）= timeSec / (distance / 1000)
    return (timeSec * 1000 / windowDistance).round();
  }

  /// 结束跑步时，获取最后一个不完整公里的配速（如果有距离的话）
  SplitPaceData? finishLastSplit(DateTime endTime) {
    if (_currentKmDistance > 0 && _currentKmStartTime != null) {
      final durationSec = endTime.difference(_currentKmStartTime!).inSeconds;
      // 换算为完整公里的等效配速
      final equivalentPace = (_currentKmDistance > 0 && durationSec > 0)
          ? (durationSec * 1000 / _currentKmDistance).round()
          : null;
      if (equivalentPace != null) {
        final split = SplitPaceData(
          kmIndex: _completedKms + 1,
          paceSecPerKm: equivalentPace,
          startTime: _currentKmStartTime!,
          endTime: endTime,
        );
        _splits.add(split);
        return split;
      }
    }
    return null;
  }

  /// 排除暂停耗时，避免分公里配速把暂停时间算进去。
  void excludePausedDuration(Duration duration) {
    if (duration <= Duration.zero || _currentKmStartTime == null) return;
    _currentKmStartTime = _currentKmStartTime!.add(duration);
  }

  /// 暂停开始时丢弃实时窗口，避免恢复后把停顿段作为移动距离累计。
  void clearRealtimeWindow() {
    _windowPoints.clear();
  }

  /// 恢复时用确认后的第一个真实移动点作为距离锚点。
  ///
  /// 锚点本身不产生距离，但下一个点会从该锚点开始累计，避免从暂停前
  /// 的旧点跨越整段暂停时间，同时保留恢复后的第一段真实移动距离。
  void seedRealtimeWindow(TrackPoint point) {
    _windowPoints
      ..clear()
      ..addLast(point);
  }

  /// 重置计算器
  void reset() {
    _windowPoints.clear();
    _totalDistanceMeters = 0;
    _currentKmDistance = 0;
    _currentKmStartTime = null;
    _completedKms = 0;
    _splits.clear();
  }

  /// Haversine 公式计算两点间距离（米）
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // 地球半径（米）
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}

/// 分公里配速数据
class SplitPaceData {
  final int kmIndex;
  final int paceSecPerKm;
  final DateTime startTime;
  final DateTime endTime;

  const SplitPaceData({
    required this.kmIndex,
    required this.paceSecPerKm,
    required this.startTime,
    required this.endTime,
  });
}
