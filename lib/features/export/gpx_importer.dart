import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:xml/xml.dart';

import '../../data/database.dart';
import '../../data/daos/route_point_dao.dart';
import '../../data/daos/run_session_dao.dart';
import '../../data/daos/split_pace_dao.dart';
import '../tracking/domain/elevation_calculator.dart';

/// GPX 文件导入器
/// 支持单轨迹和多轨迹 GPX（每条 trk 独立导入为一次跑步）
class GpxImporter {
  final RunSessionDao _sessionDao;
  final RoutePointDao _routePointDao;
  final SplitPaceDao _splitPaceDao;

  GpxImporter(this._sessionDao, this._routePointDao, this._splitPaceDao);

  /// 导入 GPX 文件（自动识别单轨迹/多轨迹）
  /// [weightKg] 用于计算卡路里（体重 × 距离km × 1.036），默认 70kg
  /// 返回 (成功数, 跳过数, 失败数, 错误列表)
  Future<({int success, int skipped, int failed, List<String> errors})>
      importFile(File file, {double weightKg = 70}) async {
    final content = await file.readAsString();
    final document = XmlDocument.parse(content);

    // 查找所有 <trk> 元素
    final trks = document.findAllElements('trk').toList();

    if (trks.isEmpty) {
      // 兼容无 <trk> 直接有 <trkpt> 的简单 GPX
      final trkpts = document.findAllElements('trkpt').toList();
      if (trkpts.isEmpty) {
        throw FormatException('GPX 文件中没有轨迹数据');
      }
      // 当作单轨迹处理
      final id = await _importTrackPoints(trkpts, null, weightKg: weightKg);
      if (id < 0) {
        return (success: 0, skipped: 1, failed: 0, errors: <String>[]);
      }
      return (success: 1, skipped: 0, failed: 0, errors: <String>[]);
    }

    // 查询已有记录用于去重
    final existingSessions = await _sessionDao.getAllSessions();
    // 使用毫秒精度去重，避免秒级截断导致不同跑步被误判为重复
    final existingStartTimes = existingSessions
        .map((s) => s.startTime.millisecondsSinceEpoch)
        .toSet();

    int success = 0;
    int skipped = 0;
    int failed = 0;
    final errors = <String>[];

    for (int i = 0; i < trks.length; i++) {
      final trk = trks[i];
      final trkName = trk.findElements('name').firstOrNull?.innerText;
      final trkpts = trk.findAllElements('trkpt').toList();

      if (trkpts.isEmpty) {
        skipped++;
        continue;
      }

      try {
        final id = await _importTrackPoints(trkpts, trkName,
            existingStartTimes: existingStartTimes,
            weightKg: weightKg);
        if (id < 0) {
          skipped++; // 去重跳过
        } else {
          success++;
        }
      } catch (e) {
        failed++;
        final label = trkName ?? '轨迹 ${i + 1}';
        errors.add('$label: $e');
      }
    }

    return (success: success, skipped: skipped, failed: failed, errors: errors);
  }

  /// 批量导入多个 GPX 文件
  /// [weightKg] 用于计算卡路里（体重 × 距离km × 1.036），默认 70kg
  Future<({int success, int skipped, int failed, List<String> errors})>
      importFiles(List<File> files, {double weightKg = 70}) async {
    int success = 0;
    int skipped = 0;
    int failed = 0;
    final errors = <String>[];

    for (final file in files) {
      try {
        final result = await importFile(file, weightKg: weightKg);
        success += result.success;
        skipped += result.skipped;
        failed += result.failed;
        errors.addAll(result.errors);
      } catch (e) {
        failed++;
        errors.add('${file.path.split('/').last}: $e');
      }
    }

    return (success: success, skipped: skipped, failed: failed, errors: errors);
  }

  /// 导入一组轨迹点，返回 session ID，去重跳过返回 -1
  Future<int> _importTrackPoints(
    List<XmlElement> trkpts,
    String? trackName, {
    Set<int>? existingStartTimes,
    double weightKg = 70,
  }) async {
    // 解析轨迹点
    final points = <_ParsedPoint>[];
    for (final trkpt in trkpts) {
      final lat = double.tryParse(trkpt.getAttribute('lat') ?? '');
      final lon = double.tryParse(trkpt.getAttribute('lon') ?? '');
      if (lat == null || lon == null) continue;
      // 校验坐标范围：纬度 [-90, 90]，经度 [-180, 180]
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;

      double? ele;
      final eleNode = trkpt.findElements('ele').firstOrNull;
      if (eleNode != null) {
        ele = double.tryParse(eleNode.innerText);
      }

      DateTime? time;
      final timeNode = trkpt.findElements('time').firstOrNull;
      if (timeNode != null) {
        time = DateTime.tryParse(timeNode.innerText);
      }

      points.add(_ParsedPoint(
        latitude: lat,
        longitude: lon,
        altitude: ele,
        timestamp: time,
      ));
    }

    if (points.isEmpty) {
      throw FormatException('没有有效的轨迹点');
    }

    // 按时间排序
    if (points.first.timestamp != null) {
      points.sort((a, b) =>
          (a.timestamp ?? DateTime(2000)).compareTo(b.timestamp ?? DateTime(2000)));
    }

    // 去重
    final startTime = points.first.timestamp ?? DateTime.now();
    if (existingStartTimes != null) {
      final startMs = startTime.millisecondsSinceEpoch;
      if (existingStartTimes.contains(startMs)) {
        return -1;
      }
      existingStartTimes.add(startMs);
    }

    final endTime = points.last.timestamp ?? startTime;
    final durationSeconds = endTime.difference(startTime).inSeconds;

    // 计算总距离
    double totalDistanceMeters = 0;
    for (int i = 1; i < points.length; i++) {
      totalDistanceMeters += _haversine(
        points[i - 1].latitude, points[i - 1].longitude,
        points[i].latitude, points[i].longitude,
      );
    }

    // 配速
    final avgPace = durationSeconds > 0 && totalDistanceMeters > 0
        ? (durationSeconds * 1000 / totalDistanceMeters).round()
        : 0;

    // 分公里配速
    final splits = _calculateSplits(points);
    final bestPace = splits.isNotEmpty
        ? splits.map((s) => s.pace).reduce((a, b) => a < b ? a : b)
        : avgPace;

    // 海拔爬升
    final elevCalc = ElevationCalculator();
    for (final p in points) {
      elevCalc.addAltitude(p.altitude);
    }
    elevCalc.finish();

    // 命名：优先用轨迹名称，否则按时间段
    final autoName = (trackName != null && trackName.isNotEmpty)
        ? trackName
        : _generateAutoName(startTime);

    // 卡路里（使用传入的体重，无法从 GPX 获取用户体重时使用默认值）
    final calories = (weightKg * totalDistanceMeters / 1000 * 1.036).round();

    // 写入 session
    final sessionId = await _sessionDao.insertSession(RunSessionsCompanion.insert(
      startTime: startTime,
      endTime: Value(endTime),
      durationSeconds: durationSeconds,
      distanceMeters: totalDistanceMeters,
      avgPaceSecPerKm: avgPace,
      bestPaceSecPerKm: bestPace,
      caloriesKcal: Value(calories),
      elevationGainMeters: Value(elevCalc.totalGainMeters),
      autoName: Value(autoName),
    ));

    // 写入轨迹点（分批 500 条）
    final pointCompanions = <RoutePointsCompanion>[];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      pointCompanions.add(RoutePointsCompanion.insert(
        sessionId: sessionId,
        latitude: p.latitude,
        longitude: p.longitude,
        altitude: Value(p.altitude),
        accuracy: 0,
        speed: i > 0 && p.timestamp != null && points[i - 1].timestamp != null
            ? _haversine(points[i - 1].latitude, points[i - 1].longitude, p.latitude, p.longitude) /
                max(1, p.timestamp!.difference(points[i - 1].timestamp!).inSeconds)
            : 0,
        timestamp: p.timestamp ?? startTime.add(Duration(seconds: i * 3)),
        orderIndex: i + 1,
      ));

      if (pointCompanions.length >= 500) {
        await _routePointDao.insertBatch(pointCompanions);
        pointCompanions.clear();
      }
    }
    if (pointCompanions.isNotEmpty) {
      await _routePointDao.insertBatch(pointCompanions);
    }

    // 写入分公里配速
    if (splits.isNotEmpty) {
      final splitCompanions = splits.map((s) => SplitPacesCompanion.insert(
        sessionId: sessionId,
        kmIndex: s.km,
        paceSecPerKm: s.pace,
        startTime: s.startTime,
        endTime: s.endTime,
      )).toList();
      await _splitPaceDao.insertBatch(splitCompanions);
    }

    return sessionId;
  }

  /// 计算分公里配速
  List<_SplitData> _calculateSplits(List<_ParsedPoint> points) {
    if (points.length < 2) return [];

    final splits = <_SplitData>[];
    double kmDistance = 0;
    int kmIndex = 0;
    DateTime? kmStartTime = points.first.timestamp;

    for (int i = 1; i < points.length; i++) {
      final dist = _haversine(
        points[i - 1].latitude, points[i - 1].longitude,
        points[i].latitude, points[i].longitude,
      );
      kmDistance += dist;

      while (kmDistance >= 1000) {
        kmIndex++;
        final kmEndTime = points[i].timestamp ?? DateTime.now();
        final pace = kmStartTime != null
            ? kmEndTime.difference(kmStartTime).inSeconds
            : 0;
        splits.add(_SplitData(
          km: kmIndex,
          pace: pace > 0 ? pace : 1,
          startTime: kmStartTime ?? DateTime.now(),
          endTime: kmEndTime,
        ));
        kmDistance -= 1000;
        kmStartTime = kmEndTime;
      }
    }

    return splits;
  }

  static String _generateAutoName(DateTime startTime) {
    final hour = startTime.hour;
    if (hour >= 5 && hour < 9) return '清晨跑';
    if (hour >= 9 && hour < 12) return '上午跑';
    if (hour >= 12 && hour < 14) return '午间跑';
    if (hour >= 14 && hour < 17) return '下午跑';
    if (hour >= 17 && hour < 19) return '傍晚跑';
    return '夜跑';
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}

class _ParsedPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime? timestamp;

  _ParsedPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
  });
}

class _SplitData {
  final int km;
  final int pace;
  final DateTime startTime;
  final DateTime endTime;

  _SplitData({
    required this.km,
    required this.pace,
    required this.startTime,
    required this.endTime,
  });
}
