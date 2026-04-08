import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// 前台服务封装
/// - Android: 启动 Foreground Service + 通知栏常驻，保持进程存活
/// - iOS: 空操作（iOS 通过 geolocator 的 AppleSettings 后台定位）
class ForegroundTaskService {

  /// 初始化（在 main() 中调用一次）
  static void init() {
    FlutterForegroundTask.initCommunicationPort();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'runpure_tracking',
        channelName: 'Solrun 跑步记录',
        channelDescription: '跑步记录中的后台定位服务',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
        enableVibration: false,
        playSound: false,
        showWhen: false,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// 启动前台服务
  /// 注意：GPS 后台保活由 geolocator 的 ForegroundNotificationConfig 负责，
  /// flutter_foreground_task 不再启动独立前台服务（避免双服务冲突）。
  /// 此方法保留接口兼容性。
  Future<void> startService() async {
    // GPS 前台服务由 geolocator 内部管理，此处不再启动 flutter_foreground_task 服务
  }

  /// 停止前台服务
  Future<void> stopService() async {
    removeDataCallback();
  }

  /// 更新通知栏数据（当前为空操作，通知由 geolocator 前台服务显示）
  void updateNotification({
    required String distance,
    required String pace,
    required String duration,
    bool isPaused = false,
  }) {
    // geolocator 的 ForegroundNotificationConfig 不支持动态更新通知内容
    // 通知固定显示"Solrun 正在记录跑步"
  }

  /// 强制更新通知（当前为空操作）
  void forceUpdateNotification({
    required String distance,
    required String pace,
    required String duration,
    bool isPaused = false,
  }) {
    // 同上
  }

  /// 注册/注销通知按钮事件回调（保留接口兼容性）
  void addDataCallback(void Function(Object) callback) {}
  void removeDataCallback() {}

  /// 请求电池优化白名单（华为/OPPO 等国产 ROM 关键）
  static Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;

    try {
      final isIgnoring =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnoring) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    } catch (e) {
      debugPrint('[ForegroundTaskService] 电池优化请求异常: $e');
    }
  }
}

/// TaskHandler 回调入口（必须是顶层函数）
@pragma('vm:entry-point')
void _startTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_SolrunTaskHandler());
}

/// 极简 TaskHandler — GPS 逻辑在主 isolate 的 LocationService 中
/// 前台服务仅负责保持进程存活
class _SolrunTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // GPS 流由 LocationService 管理，此处无需操作
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 通知更新由 TrackingNotifier 驱动，此处作为心跳保活
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // 清理（如有需要）
  }

  @override
  void onNotificationButtonPressed(String id) {
    // 将按钮事件转发到主 isolate
    FlutterForegroundTask.sendDataToMain({'action': id});
  }

  @override
  void onNotificationPressed() {
    // 点击通知返回 App
    FlutterForegroundTask.launchApp();
  }
}
