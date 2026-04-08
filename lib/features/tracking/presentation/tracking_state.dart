import '../domain/pace_calculator.dart';

/// 运动状态枚举
enum TrackingStatus {
  idle,       // 未开始
  gpsWaiting, // 等待 GPS 信号
  running,    // 运动中
  paused,     // 手动暂停
  autoPaused, // 自动暂停
  finished,   // 已结束
}

/// 运动中页面的不可变状态
class TrackingState {
  final TrackingStatus status;
  final double distanceMeters;
  final int durationSeconds; // 运动时长（不含暂停）
  final int? currentPaceSecPerKm;
  final int caloriesKcal;
  final List<TrackPoint> recentPoints; // 用于地图显示的近期轨迹点
  final int totalPointCount; // 总点数（含已落库）
  final String? errorMessage;

  const TrackingState({
    this.status = TrackingStatus.idle,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.currentPaceSecPerKm,
    this.caloriesKcal = 0,
    this.recentPoints = const [],
    this.totalPointCount = 0,
    this.errorMessage,
  });

  /// 距离（公里）
  double get distanceKm => distanceMeters / 1000;

  /// 格式化距离（如 "5.24"）
  String get distanceDisplay => distanceKm.toStringAsFixed(2);

  /// 格式化时长（如 "32:18"）
  String get durationDisplay {
    final min = durationSeconds ~/ 60;
    final sec = durationSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// 格式化配速（如 "5'42\""）
  String get paceDisplay {
    if (currentPaceSecPerKm == null || currentPaceSecPerKm == 0) return '--\'--"';
    final min = currentPaceSecPerKm! ~/ 60;
    final sec = currentPaceSecPerKm! % 60;
    return '$min\'${sec.toString().padLeft(2, '0')}"';
  }

  /// 是否正在运动（running 或 autoPaused 都算"运动中"）
  bool get isActive => status == TrackingStatus.running ||
      status == TrackingStatus.paused ||
      status == TrackingStatus.autoPaused;

  TrackingState copyWith({
    TrackingStatus? status,
    double? distanceMeters,
    int? durationSeconds,
    int? currentPaceSecPerKm,
    int? caloriesKcal,
    List<TrackPoint>? recentPoints,
    int? totalPointCount,
    String? errorMessage,
  }) {
    return TrackingState(
      status: status ?? this.status,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      currentPaceSecPerKm: currentPaceSecPerKm ?? this.currentPaceSecPerKm,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      recentPoints: recentPoints ?? this.recentPoints,
      totalPointCount: totalPointCount ?? this.totalPointCount,
      errorMessage: errorMessage,
    );
  }
}
