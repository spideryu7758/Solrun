import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../domain/pace_calculator.dart';

/// GPS 定位服务
///
/// 平台策略：
/// - Android: 原生 Kotlin ForegroundService（独立于 Flutter 引擎，荣耀/华为兼容）
///   通过 MethodChannel 控制启停，EventChannel 接收 GPS 数据
/// - iOS: geolocator 的 AppleSettings（background location mode）
class LocationService {
  /// 精度过滤阈值（米）— iOS 端使用，Android 端由原生层过滤
  static const double maxAccuracyMeters = 15.0;

  // Android 原生通道
  static const _methodChannel = MethodChannel('com.runpure.run_pure/gps');
  static const _eventChannel = EventChannel('com.runpure.run_pure/gps_stream');

  // iOS geolocator
  StreamSubscription<Position>? _iosSubscription;

  // Android 原生 EventChannel
  StreamSubscription<dynamic>? _androidSubscription;

  // 统一输出流
  final _controller = StreamController<TrackPoint>.broadcast();

  /// 过滤后的 GPS 轨迹点流
  Stream<TrackPoint> get trackPointStream => _controller.stream;

  /// 请求定位权限
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    if (Platform.isAndroid) {
      // Android 需要后台定位 + 通知权限
      final bgGranted = await _ensureBackgroundLocationPermission();
      if (!bgGranted) return false;
      await _ensureNotificationPermission();
    }

    return true;
  }

  Future<bool> _ensureBackgroundLocationPermission() async {
    final status = await ph.Permission.locationAlways.status;
    if (status.isGranted) return true;
    final requested = await ph.Permission.locationAlways.request();
    if (requested.isGranted) return true;
    if (requested.isPermanentlyDenied || requested.isDenied) {
      await ph.openAppSettings();
    }
    return false;
  }

  Future<void> _ensureNotificationPermission() async {
    final status = await ph.Permission.notification.status;
    if (status.isGranted || status.isLimited) return;
    await ph.Permission.notification.request();
  }

  /// 开始定位流
  Future<void> startTracking({bool isPaused = false}) async {
    if (Platform.isAndroid) {
      await _startAndroid();
    } else {
      await _startIOS(isPaused: isPaused);
    }
  }

  /// 切换采样频率（暂停/恢复时调用）
  /// Android: 原生服务固定 3 秒采样，不需要切换
  /// iOS: 需要重建流
  Future<void> updateInterval({required bool isPaused}) async {
    if (Platform.isIOS) {
      await _startIOS(isPaused: isPaused);
    }
    // Android 原生服务固定高频采样，暂停由 Dart 层控制（不转发数据即可）
  }

  /// 停止定位流
  Future<void> stopTracking() async {
    if (Platform.isAndroid) {
      await _stopAndroid();
    } else {
      await _stopIOS();
    }
  }

  /// 强制停止（App 退出时）
  Future<void> forceStop() async {
    await stopTracking();
  }

  /// 获取当前位置（单次）
  Future<TrackPoint?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return TrackPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed >= 0 ? position.speed : 0,
        timestamp: position.timestamp,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    forceStop();
    _controller.close();
  }

  // ==================== Android 原生前台服务 ====================

  Future<void> _startAndroid() async {
    // 如果已在监听原生流，不重复订阅
    if (_androidSubscription != null) return;

    try {
      // 启动原生前台 GPS 服务
      await _methodChannel.invokeMethod('startTracking');
      debugPrint('[LocationService] Android 原生 GPS 服务已启动');
    } catch (e) {
      debugPrint('[LocationService] 启动原生服务异常: $e');
    }

    // 订阅原生 EventChannel 的 GPS 数据流
    _androidSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic data) {
        if (data is Map) {
          final point = TrackPoint(
            latitude: (data['latitude'] as num).toDouble(),
            longitude: (data['longitude'] as num).toDouble(),
            altitude: data['altitude'] != null ? (data['altitude'] as num).toDouble() : null,
            accuracy: (data['accuracy'] as num).toDouble(),
            speed: (data['speed'] as num).toDouble(),
            timestamp: DateTime.fromMillisecondsSinceEpoch((data['timestamp'] as num).toInt()),
          );
          _controller.add(point);
        }
      },
      onError: (error) {
        debugPrint('[LocationService] Android GPS 流错误: $error');
        _androidSubscription = null;
      },
    );
  }

  Future<void> _stopAndroid() async {
    await _androidSubscription?.cancel();
    _androidSubscription = null;
    try {
      await _methodChannel.invokeMethod('stopTracking');
      debugPrint('[LocationService] Android 原生 GPS 服务已停止');
    } catch (e) {
      debugPrint('[LocationService] 停止原生服务异常: $e');
    }
  }

  // ==================== iOS geolocator ====================

  Future<void> _startIOS({bool isPaused = false}) async {
    await _stopIOS();
    _iosSubscription = Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      ),
    ).listen(
      (position) {
        if (position.accuracy > maxAccuracyMeters) return;
        _controller.add(TrackPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          altitude: position.altitude,
          accuracy: position.accuracy,
          speed: position.speed >= 0 ? position.speed : 0,
          timestamp: position.timestamp,
        ));
      },
      onError: (error) {
        debugPrint('[LocationService] iOS GPS 流错误: $error');
        _iosSubscription = null;
      },
    );
  }

  Future<void> _stopIOS() async {
    await _iosSubscription?.cancel();
    _iosSubscription = null;
  }
}
