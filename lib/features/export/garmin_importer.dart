import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../data/database.dart';
import '../../data/daos/run_session_dao.dart';

/// Garmin Connect 批量导出 JSON 导入器
///
/// 解析 summarizedActivities JSON → 筛选跑步活动 → 写入 RunSession
/// 注意：Garmin 批量导出不含 GPS 轨迹，导入的记录无 RoutePoints
class GarminImporter {
  final RunSessionDao _sessionDao;

  /// 跑步相关的活动类型
  static const _runningTypes = {'running', 'trail_running', 'treadmill_running'};

  GarminImporter(this._sessionDao);

  /// 导入 Garmin summarizedActivities JSON 文件
  ///
  /// [weightKg] 用于计算卡路里（体重 × 距离km × 1.036）
  /// 返回 (成功数, 跳过数, 失败数, 错误列表)
  Future<({int success, int skipped, int failed, List<String> errors})>
      importFile(File file, {double weightKg = 70}) async {
    final content = await file.readAsString();
    final json = jsonDecode(content);

    // 解析 Garmin 导出的 JSON 结构
    final List<dynamic> activities = _extractActivities(json);
    if (activities.isEmpty) {
      throw FormatException('未找到活动数据（需要 summarizedActivitiesExport 字段）');
    }

    // 筛选跑步活动
    final runActivities = activities.where((a) {
      final type = a['activityType']?.toString() ?? '';
      return _runningTypes.contains(type);
    }).toList();

    if (runActivities.isEmpty) {
      throw FormatException('文件中没有跑步记录（共 ${activities.length} 条活动）');
    }

    // 查询已有记录的 startTime 集合，用于去重
    final existingSessions = await _sessionDao.getAllSessions();
    final existingStartTimes = existingSessions
        .map((s) => s.startTime.millisecondsSinceEpoch ~/ 1000) // 精确到秒
        .toSet();

    int success = 0;
    int skipped = 0;
    int failed = 0;
    final errors = <String>[];

    for (final activity in runActivities) {
      try {
        final result = _importActivity(activity, existingStartTimes, weightKg);
        if (result == null) {
          skipped++; // 已存在，跳过
          continue;
        }
        await _sessionDao.insertSession(result);
        // 把新导入的时间戳也加入去重集合
        existingStartTimes.add(
          result.startTime.value.millisecondsSinceEpoch ~/ 1000,
        );
        success++;
      } catch (e) {
        failed++;
        final name = activity['name']?.toString() ?? '未知活动';
        final ts = activity['startTimeLocal'];
        errors.add('$name (${_formatTimestamp(ts)}): $e');
      }
    }

    return (success: success, skipped: skipped, failed: failed, errors: errors);
  }

  /// 从 JSON 中提取活动列表，兼容多种结构
  List<dynamic> _extractActivities(dynamic json) {
    // 结构1: [{"summarizedActivitiesExport": [...]}]
    if (json is List && json.isNotEmpty && json[0] is Map) {
      final export = json[0]['summarizedActivitiesExport'];
      if (export is List) return export;
    }
    // 结构2: {"summarizedActivitiesExport": [...]}
    if (json is Map) {
      final export = json['summarizedActivitiesExport'];
      if (export is List) return export;
    }
    // 结构3: 直接是活动数组
    if (json is List && json.isNotEmpty && json[0] is Map && json[0].containsKey('activityType')) {
      return json;
    }
    return [];
  }

  /// 将单条 Garmin 活动转为 RunSessionsCompanion
  /// 返回 null 表示已存在（去重）
  RunSessionsCompanion? _importActivity(
    Map<String, dynamic> activity,
    Set<int> existingStartTimes,
    double weightKg,
  ) {
    // 时间戳（Garmin 用毫秒 Unix 时间戳）
    final startTimeMs = (activity['startTimeLocal'] as num?)?.toInt();
    if (startTimeMs == null || startTimeMs <= 0) {
      throw FormatException('缺少有效的开始时间');
    }
    final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);

    // 去重：同一秒开始的记录视为重复
    if (existingStartTimes.contains(startTimeMs ~/ 1000)) {
      return null;
    }

    // 距离：Garmin 单位 cm → m
    final distanceMeters = ((activity['distance'] as num?) ?? 0) / 100;
    if (distanceMeters <= 0) {
      throw FormatException('距离为 0');
    }

    // 时长：Garmin 单位 ms → s
    final durationSeconds = (((activity['duration'] as num?) ?? 0) / 1000).round();
    if (durationSeconds <= 0) {
      throw FormatException('时长为 0');
    }

    final endTime = startTime.add(Duration(seconds: durationSeconds));

    // 配速：秒/公里
    final distanceKm = distanceMeters / 1000;
    final avgPace = (durationSeconds / distanceKm).round();

    // 最快配速（Garmin 有 maxSpeed，单位 m/s）
    // maxSpeed → 秒/公里 = 1000 / maxSpeed
    final maxSpeed = (activity['maxSpeed'] as num?)?.toDouble() ?? 0;
    final bestPace = maxSpeed > 0 ? (1000 / maxSpeed).round() : avgPace;

    // 海拔爬升：Garmin 单位 cm → m，异常值过滤
    var elevationGain = ((activity['elevationGain'] as num?) ?? 0) / 100;
    // 每公里爬升 > 200m 视为异常数据
    if (distanceKm > 0 && elevationGain / distanceKm > 200) {
      elevationGain = 0;
    }

    // 卡路里：用 Solrun 统一公式重算
    final calories = (weightKg * distanceKm * 1.036).round();

    // 活动名称
    final autoName = (activity['name'] as String?) ?? _typeToName(activity['activityType']?.toString() ?? '');

    return RunSessionsCompanion.insert(
      startTime: startTime,
      endTime: Value(endTime),
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      avgPaceSecPerKm: avgPace,
      bestPaceSecPerKm: bestPace,
      caloriesKcal: Value(calories),
      elevationGainMeters: Value(elevationGain),
      autoName: Value(autoName),
    );
  }

  /// 活动类型 → 中文名称（Garmin 已有中文 name 时不会调用）
  static String _typeToName(String type) {
    switch (type) {
      case 'running': return '跑步';
      case 'trail_running': return '越野跑';
      case 'treadmill_running': return '跑步机';
      default: return '跑步';
    }
  }

  static String _formatTimestamp(dynamic ts) {
    if (ts is num && ts > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return '未知日期';
  }
}
