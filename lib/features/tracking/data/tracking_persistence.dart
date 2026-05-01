import 'package:drift/drift.dart';

import '../../../data/database.dart';
import '../../../data/daos/route_point_dao.dart';
import '../../../data/daos/run_session_dao.dart';
import '../../../data/daos/split_pace_dao.dart';
import '../../../data/run_session_status.dart';
import '../domain/pace_calculator.dart';
import 'checkpoint_service.dart';

/// 跑步数据持久化服务
///
/// 负责轨迹点分批落库、检查点读写、RunSession 更新、SplitPace 写入。
/// 不持有运动状态，由 TrackingNotifier 编排调用。
class TrackingPersistence {
  final RunSessionDao _runSessionDao;
  final RoutePointDao _routePointDao;
  final SplitPaceDao _splitPaceDao;
  final CheckpointService _checkpointService;

  TrackingPersistence({
    required RunSessionDao runSessionDao,
    required RoutePointDao routePointDao,
    required SplitPaceDao splitPaceDao,
    required CheckpointService checkpointService,
  }) : _runSessionDao = runSessionDao,
       _routePointDao = routePointDao,
       _splitPaceDao = splitPaceDao,
       _checkpointService = checkpointService;

  /// 分批落库（释放内存）
  ///
  /// 将缓冲区中的轨迹点写入数据库，清空缓冲区并返回本次写入的条数。
  /// [buffer] 内存中的轨迹点缓冲（调用方负责 clear）
  /// [sessionId] 当前跑步记录 ID
  /// [flushedCount] 已落库的点数（用于计算 orderIndex）
  Future<int> flushPointBuffer({
    required List<TrackPoint> buffer,
    required int sessionId,
    required int flushedCount,
  }) async {
    if (buffer.isEmpty) return 0;

    final companions = buffer
        .asMap()
        .entries
        .map(
          (e) => RoutePointsCompanion.insert(
            sessionId: sessionId,
            latitude: e.value.latitude,
            longitude: e.value.longitude,
            altitude: Value(e.value.altitude),
            accuracy: e.value.accuracy,
            speed: e.value.speed,
            timestamp: e.value.timestamp,
            orderIndex: flushedCount + e.key + 1,
          ),
        )
        .toList();

    await _routePointDao.insertBatch(companions);
    await _checkpointService.clearPointsLog();
    return buffer.length;
  }

  /// 写入检查点元数据
  Future<void> writeCheckpoint({
    required DateTime startTime,
    required int durationSeconds,
    required double distanceMeters,
    required List<SplitPaceData> splits,
    required int flushedPointCount,
  }) async {
    await _checkpointService.writeMeta(
      CheckpointMeta(
        startTime: startTime.toIso8601String(),
        durationSeconds: durationSeconds,
        distanceMeters: distanceMeters,
        splitPaces: splits
            .map((s) => {'km': s.kmIndex, 'pace': s.paceSecPerKm})
            .toList(),
        flushedPointCount: flushedPointCount,
        lastUpdated: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// 删除检查点文件
  Future<void> deleteCheckpoint() async {
    await _checkpointService.deleteCheckpoint();
  }

  /// 保存跑步记录（从 incomplete → completed）+ 写入分公里配速
  Future<void> saveSession({
    required int sessionId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSeconds,
    required double distanceMeters,
    required int avgPace,
    required int bestPace,
    required int caloriesKcal,
    required double elevationGainMeters,
    required String autoName,
    required String? city,
    required String? weather,
    required List<SplitPaceData> splits,
  }) async {
    // 更新 RunSession 记录
    final session = RunSessionsCompanion(
      id: Value(sessionId),
      status: const Value(RunSessionStatus.completed),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationSeconds: Value(durationSeconds),
      distanceMeters: Value(distanceMeters),
      avgPaceSecPerKm: Value(avgPace),
      bestPaceSecPerKm: Value(bestPace),
      caloriesKcal: Value(caloriesKcal),
      elevationGainMeters: Value(elevationGainMeters),
      autoName: Value(autoName),
      city: Value(city),
      weather: Value(weather),
    );
    await _runSessionDao.updateSession(session);

    // 写入分公里配速
    if (splits.isNotEmpty) {
      final splitCompanions = splits
          .map(
            (s) => SplitPacesCompanion.insert(
              sessionId: sessionId,
              kmIndex: s.kmIndex,
              paceSecPerKm: s.paceSecPerKm,
              startTime: s.startTime,
              endTime: s.endTime,
            ),
          )
          .toList();
      await _splitPaceDao.insertBatch(splitCompanions);
    }
  }

  /// 跑步完成后的在线补充信息更新。
  ///
  /// 不重复写入分公里，避免异步补充城市/天气/DEM 海拔时产生重复 split。
  Future<void> updateSessionEnrichment({
    required int sessionId,
    required double elevationGainMeters,
    required String fallbackAutoName,
    required String enrichedAutoName,
    required String? city,
    required String? weather,
  }) {
    return _runSessionDao.updateSessionEnrichment(
      id: sessionId,
      elevationGainMeters: elevationGainMeters,
      fallbackAutoName: fallbackAutoName,
      enrichedAutoName: enrichedAutoName,
      city: city,
      weather: weather,
    );
  }

  /// 追加轨迹点到检查点日志（每个 GPS 点实时写入）
  Future<void> appendPointToLog(TrackPoint point, int orderIndex) {
    return _checkpointService.appendPoint(point, orderIndex);
  }

  /// 获取第一个轨迹点（用于反向地理编码）
  Future<RoutePoint?> getFirstPoint(int sessionId) {
    return _routePointDao.getFirstPoint(sessionId);
  }
}
