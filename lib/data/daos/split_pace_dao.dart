import 'package:drift/drift.dart';

import '../database.dart';

part 'split_pace_dao.g.dart';

@DriftAccessor(tables: [SplitPaces])
class SplitPaceDao extends DatabaseAccessor<AppDatabase> with _$SplitPaceDaoMixin {
  SplitPaceDao(super.db);

  /// 批量插入分公里配速（跑步结束时一次性写入）
  Future<void> insertBatch(List<SplitPacesCompanion> splits) {
    return batch((b) {
      b.insertAll(splitPaces, splits);
    });
  }

  /// 按 sessionId 查询分公里配速（按 kmIndex 排序）
  Future<List<SplitPace>> getSplitsBySession(int sessionId) {
    return (select(splitPaces)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.kmIndex)]))
        .get();
  }

  /// 按 sessionId 删除
  Future<int> deleteBySession(int sessionId) {
    return (delete(splitPaces)..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
