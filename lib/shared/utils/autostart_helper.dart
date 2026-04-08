import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 国产 ROM 自启动管理引导
/// 华为/小米/OPPO/vivo/三星等厂商有独立的自启动白名单机制，
/// 不在白名单内的 App 即使有前台服务也可能被杀。
class AutostartHelper {
  static const _prefKey = 'autostart_guide_shown';

  /// 厂商 → 应用启动管理 Intent 映射表（按优先级排列，逐个尝试）
  static final _manufacturerIntents = <String, List<Map<String, String>>>{
    'huawei': [
      // HarmonyOS 3.0+ 应用启动管理（新版）
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity',
      },
      // EMUI 旧版
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity',
      },
      // 受保护应用
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.optimize.process.ProtectActivity',
      },
    ],
    'honor': [
      // MagicOS / HarmonyOS 新版应用启动管理
      {
        'package': 'com.hihonor.systemmanager',
        'class': 'com.hihonor.systemmanager.appcontrol.activity.StartupAppControlActivity',
      },
      {
        'package': 'com.hihonor.systemmanager',
        'class': 'com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity',
      },
      // 回退到华为系统管理器（部分荣耀设备共用）
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity',
      },
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity',
      },
    ],
    'xiaomi': [
      {
        'package': 'com.miui.securitycenter',
        'class': 'com.miui.permcenter.autostart.AutoStartManagementActivity',
      },
    ],
    'redmi': [
      {
        'package': 'com.miui.securitycenter',
        'class': 'com.miui.permcenter.autostart.AutoStartManagementActivity',
      },
    ],
    'oppo': [
      {
        'package': 'com.coloros.safecenter',
        'class': 'com.coloros.safecenter.startupapp.StartupAppListActivity',
      },
      {
        'package': 'com.oppo.safe',
        'class': 'com.oppo.safe.permission.startup.StartupAppListActivity',
      },
    ],
    'realme': [
      {
        'package': 'com.coloros.safecenter',
        'class': 'com.coloros.safecenter.startupapp.StartupAppListActivity',
      },
    ],
    'vivo': [
      {
        'package': 'com.vivo.permissionmanager',
        'class': 'com.vivo.permissionmanager.activity.BgStartUpManagerActivity',
      },
      {
        'package': 'com.iqoo.secure',
        'class': 'com.iqoo.secure.ui.phoneoptimize.BgStartUpManager',
      },
    ],
    'samsung': [
      {
        'package': 'com.samsung.android.lool',
        'class': 'com.samsung.android.sm.battery.ui.BatteryActivity',
      },
    ],
    'oneplus': [
      {
        'package': 'com.coloros.safecenter',
        'class': 'com.coloros.safecenter.startupapp.StartupAppListActivity',
      },
    ],
    'meizu': [
      {
        'package': 'com.meizu.safe',
        'class': 'com.meizu.safe.security.SHOW_APPSEC',
      },
    ],
  };

  /// 厂商 → 电池/后台管理 Intent 映射表
  static final _batteryIntents = <String, List<Map<String, String>>>{
    'huawei': [
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.power.ui.HwPowerManagerActivity',
      },
    ],
    'honor': [
      {
        'package': 'com.hihonor.systemmanager',
        'class': 'com.hihonor.systemmanager.power.ui.HwPowerManagerActivity',
      },
      {
        'package': 'com.huawei.systemmanager',
        'class': 'com.huawei.systemmanager.power.ui.HwPowerManagerActivity',
      },
    ],
  };

  static const _platform = MethodChannel('com.runpure.run_pure/autostart');

  /// 显示自启动引导弹窗（首次跑步时调用）
  static Future<void> showGuideIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) ?? false) return;

    // 通过 MethodChannel 获取厂商信息
    String manufacturer;
    try {
      manufacturer = await _platform.invokeMethod<String>('getManufacturer') ?? '';
      manufacturer = manufacturer.toLowerCase().trim();
    } catch (_) {
      return;
    }

    if (!_manufacturerIntents.containsKey(manufacturer)) {
      // 非目标厂商，标记已处理
      await prefs.setBool(_prefKey, true);
      return;
    }

    if (!context.mounted) return;

    final brandName = _getBrandDisplayName(manufacturer);

    // 第一步：应用启动管理（自启动 + 后台活动）
    final shouldOpenStartup = await _showGuideDialog(
      context,
      title: '后台运行权限',
      content: '检测到您使用的是 $brandName 设备。\n\n'
          '为确保跑步记录不中断，请进行以下设置：\n\n'
          '1. 找到 Solrun\n'
          '2. 关闭"自动管理"\n'
          '3. 开启"允许自启动"和"允许后台活动"\n\n'
          '点击"去设置"将跳转到应用启动管理页面。',
    );

    if (shouldOpenStartup) {
      await _openSettings(manufacturer, _manufacturerIntents);

      // 第二步：电池管理（仅华为/荣耀需要）
      if (_batteryIntents.containsKey(manufacturer) && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!context.mounted) {
          await prefs.setBool(_prefKey, true);
          return;
        }

        final shouldOpenBattery = await _showGuideDialog(
          context,
          title: '电池优化设置',
          content: '还需要一步：在电池管理中将 Solrun 设为"不受限"，\n'
              '防止系统在跑步时限制 GPS 定位。\n\n'
              '点击"去设置"跳转到电池管理页面。',
        );

        if (shouldOpenBattery) {
          await _openSettings(manufacturer, _batteryIntents);
        }
      }
    }

    await prefs.setBool(_prefKey, true);
  }

  /// 显示引导弹窗，返回用户是否点击了"去设置"
  static Future<bool> _showGuideDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('稍后再说'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 跳转到厂商设置页面（支持应用启动管理和电池管理）
  static Future<void> _openSettings(
    String manufacturer,
    Map<String, List<Map<String, String>>> intentMap,
  ) async {
    final intents = intentMap[manufacturer];
    if (intents == null || intents.isEmpty) {
      // 无对应 Intent，回退到应用详情页
      try {
        await _platform.invokeMethod<void>('openAppSettings');
      } catch (_) {}
      return;
    }

    for (final intent in intents) {
      try {
        final success = await _platform.invokeMethod<bool>('openActivity', {
          'package': intent['package'],
          'class': intent['class'],
        });
        if (success == true) return;
      } catch (_) {
        continue;
      }
    }

    // 所有 Intent 都失败，回退到应用详情页
    try {
      await _platform.invokeMethod<void>('openAppSettings');
    } catch (_) {}
  }

  /// 厂商显示名称
  static String _getBrandDisplayName(String manufacturer) {
    const names = {
      'huawei': '华为',
      'honor': '荣耀',
      'xiaomi': '小米',
      'redmi': '红米',
      'oppo': 'OPPO',
      'realme': 'realme',
      'vivo': 'vivo',
      'samsung': '三星',
      'oneplus': '一加',
      'meizu': '魅族',
    };
    return names[manufacturer] ?? manufacturer;
  }
}
