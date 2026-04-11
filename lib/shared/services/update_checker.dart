import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// 应用更新检测服务
///
/// 启动时静默请求服务器 version.json，对比本地版本号，
/// 有新版本时弹窗提示用户下载。
class UpdateChecker {
  static const _updateUrl = 'http://solrun.greatwaycloud.com:8080/version.json';
  static const _timeout = Duration(seconds: 5);

  /// 检查更新（静默，失败不影响正常使用）
  /// debug 模式跳过，避免开发时版本号不同步误弹更新
  static Future<void> check(BuildContext context) async {
    if (kDebugMode) return;
    try {
      final info = await _fetchVersionInfo();
      if (info == null) return;

      // 获取当前版本
      final currentVersion = await _getCurrentVersion();
      if (currentVersion == null) return;

      // 对比版本号
      if (_isNewer(info['version'] as String, currentVersion)) {
        if (!context.mounted) return;
        _showUpdateDialog(
          context,
          version: info['version'] as String,
          changelog: info['changelog'] as String? ?? '',
          url: info['url'] as String,
          force: info['force'] as bool? ?? false,
        );
      }
    } catch (_) {
      // 更新检查失败不影响 App 正常使用
    }
  }

  /// 请求服务器获取最新版本信息
  static Future<Map<String, dynamic>?> _fetchVersionInfo() async {
    final client = HttpClient();
    client.connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(Uri.parse(_updateUrl));
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != 200) return null;
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_timeout);
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  /// 获取当前 App 版本号
  static Future<String?> _getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return null;
    }
  }

  /// 比较版本号：remote 是否比 current 新
  static bool _isNewer(String remote, String current) {
    final r = remote.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (int i = 0; i < 3; i++) {
      final rv = i < r.length ? (r[i] ?? 0) : 0;
      final cv = i < c.length ? (c[i] ?? 0) : 0;
      if (rv > cv) return true;
      if (rv < cv) return false;
    }
    return false;
  }

  /// 弹窗提示更新
  static void _showUpdateDialog(
    BuildContext context, {
    required String version,
    required String changelog,
    required String url,
    required bool force,
  }) {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => AlertDialog(
        title: Text(s?.updateAvailableTitle ?? '发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v$version'),
            if (changelog.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                changelog,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s?.updateLater ?? '稍后'),
            ),
          FilledButton(
            onPressed: () {
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              if (!force) Navigator.of(ctx).pop();
            },
            child: Text(s?.updateNow ?? '立即更新'),
          ),
        ],
      ),
    );
  }
}
