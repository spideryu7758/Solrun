import 'package:drift/drift.dart';

import '../database.dart';

part 'route_point_dao.g.dart';

@DriftAccessor(tables: [RoutePoints])
class RoutePointDao extends DatabaseAccessor<AppDatabase> with _$RoutePointDaoMixin {
  RoutePointDao(super.db);

  /// 批量插入轨迹点（事务内执行，500 条约 50ms）
  Future<void> insertBatch(List<RoutePointsCompanion> points) {
    return batch((b) {
      b.insertAll(routePoints, points);
    });
  }

  /// 按 sessionId 查询所有轨迹点（按 orderIndex 排序）
  Future<List<RoutePoint>> getPointsBySession(int sessionId) {
    return (select(routePoints)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// 按 sessionId 查询轨迹点数量
  Future<int> getPointCountBySession(int sessionId) async {
    final count = routePoints.id.count();
    final query = selectOnly(routePoints)
      ..addColumns([count])
      ..where(routePoints.sessionId.equals(sessionId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 按 sessionId 查询最大 orderIndex（崩溃恢复去重用）
  Future<int> getMaxOrderIndex(int sessionId) async {
    final maxIdx = routePoints.orderIndex.max();
    final query = selectOnly(routePoints)
      ..addColumns([maxIdx])
      ..where(routePoints.sessionId.equals(sessionId));
    final result = await query.getSingle();
    return result.read(maxIdx) ?? 0;
  }

  /// 按 sessionId 获取第一个轨迹点（用于反向地理编码）
  Future<RoutePoint?> getFirstPoint(int sessionId) {
    return (select(routePoints)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 按 sessionId 删除所有轨迹点
  Future<int> deleteBySession(int sessionId) {
    return (delete(routePoints)..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
