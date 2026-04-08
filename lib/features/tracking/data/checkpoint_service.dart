import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../domain/pace_calculator.dart';

/// 检查点服务 — 崩溃恢复用
/// - meta.json：每 30 秒覆写元数据（<1KB）
/// - points.log：每个 GPS 点追加一行（~100 字节/条）
/// - 存储位置：applicationSupportDirectory（不会被系统自动清理）
class CheckpointService {
  static const String _metaFileName = 'checkpoint_meta.json';
  static const String _pointsFileName = 'checkpoint_points.log';

  Directory? _checkpointDir;

  Future<Directory> _getDir() async {
    if (_checkpointDir != null) return _checkpointDir!;
    final appSupport = await getApplicationSupportDirectory();
    _checkpointDir = Directory(p.join(appSupport.path, 'checkpoint'));
    if (!await _checkpointDir!.exists()) {
      await _checkpointDir!.create(recursive: true);
    }
    return _checkpointDir!;
  }

  /// 写入元数据检查点（每 30 秒覆写）
  Future<void> writeMeta(CheckpointMeta meta) async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, _metaFileName));
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  /// 追加轨迹点到日志（每个 GPS 点）
  Future<void> appendPoint(TrackPoint point, int orderIndex) async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, _pointsFileName));
    final line = jsonEncode({
      'lat': point.latitude,
      'lng': point.longitude,
      'alt': point.altitude,
      'acc': point.accuracy,
      'spd': point.speed,
      'ts': point.timestamp.toIso8601String(),
      'idx': orderIndex,
    });
    await file.writeAsString('$line\n', mode: FileMode.append);
  }

  /// 清空轨迹日志（分批落库后调用）
  Future<void> clearPointsLog() async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, _pointsFileName));
    if (await file.exists()) {
      await file.writeAsString('');
    }
  }

  /// 检测是否存在未完成的检查点
  Future<bool> hasCheckpoint() async {
    final dir = await _getDir();
    final metaFile = File(p.join(dir.path, _metaFileName));
    return metaFile.existsSync();
  }

  /// 读取元数据检查点
  Future<CheckpointMeta?> readMeta() async {
    final dir = await _getDir();
    final metaFile = File(p.join(dir.path, _metaFileName));
    if (!await metaFile.exists()) return null;
    try {
      final content = await metaFile.readAsString();
      return CheckpointMeta.fromJson(jsonDecode(content));
    } catch (_) {
      return null;
    }
  }

  /// 读取轨迹日志中的所有点（恢复用）
  Future<List<LoggedPoint>> readPointsLog() async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, _pointsFileName));
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    final points = <LoggedPoint>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        points.add(LoggedPoint(
          latitude: (json['lat'] as num).toDouble(),
          longitude: (json['lng'] as num).toDouble(),
          altitude: json['alt'] != null ? (json['alt'] as num).toDouble() : null,
          accuracy: (json['acc'] as num).toDouble(),
          speed: (json['spd'] as num).toDouble(),
          timestamp: DateTime.parse(json['ts'] as String),
          orderIndex: json['idx'] as int,
        ));
      } catch (_) {
        // 跳过损坏的行（部分写入的最后一行）
        continue;
      }
    }
    return points;
  }

  /// 删除所有检查点文件
  Future<void> deleteCheckpoint() async {
    final dir = await _getDir();
    final metaFile = File(p.join(dir.path, _metaFileName));
    final pointsFile = File(p.join(dir.path, _pointsFileName));
    if (await metaFile.exists()) await metaFile.delete();
    if (await pointsFile.exists()) await pointsFile.delete();
  }
}

/// 检查点元数据
class CheckpointMeta {
  final int? sessionId;
  final String startTime;
  final int durationSeconds;
  final double distanceMeters;
  final List<Map<String, dynamic>> splitPaces;
  final int flushedPointCount; // 已落库的点数
  final String lastUpdated;

  const CheckpointMeta({
    this.sessionId,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.splitPaces,
    required this.flushedPointCount,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'startTime': startTime,
    'durationSeconds': durationSeconds,
    'distanceMeters': distanceMeters,
    'splitPaces': splitPaces,
    'flushedPointCount': flushedPointCount,
    'lastUpdated': lastUpdated,
  };

  factory CheckpointMeta.fromJson(Map<String, dynamic> json) => CheckpointMeta(
    sessionId: json['sessionId'] as int?,
    startTime: json['startTime'] as String,
    durationSeconds: json['durationSeconds'] as int,
    distanceMeters: (json['distanceMeters'] as num).toDouble(),
    splitPaces: (json['splitPaces'] as List).cast<Map<String, dynamic>>(),
    flushedPointCount: json['flushedPointCount'] as int,
    lastUpdated: json['lastUpdated'] as String,
  );
}

/// 日志中的轨迹点
class LoggedPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final double speed;
  final DateTime timestamp;
  final int orderIndex;

  const LoggedPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
    required this.orderIndex,
  });
}
