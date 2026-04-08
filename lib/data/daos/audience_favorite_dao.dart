import 'package:drift/drift.dart';

import '../database.dart';

part 'audience_favorite_dao.g.dart';

@DriftAccessor(tables: [AudienceFavorites])
class AudienceFavoriteDao extends DatabaseAccessor<AppDatabase>
    with _$AudienceFavoriteDaoMixin {
  static const int maxFavorites = 2;

  AudienceFavoriteDao(super.db);

  /// 添加粉丝团成员
  Future<int> insertFavorite(AudienceFavoritesCompanion favorite) {
    return into(audienceFavorites).insert(favorite);
  }

  /// 获取全部粉丝团成员（上限 2 条）
  Future<List<AudienceFavorite>> getAll() {
    return (select(audienceFavorites)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// 当前粉丝团数量
  Future<int> count() async {
    final countExpr = audienceFavorites.id.count();
    final query = selectOnly(audienceFavorites)..addColumns([countExpr]);
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// 粉丝团是否已满（上限 2 条）
  Future<bool> isFull() async => await count() >= maxFavorites;

  /// 原子插入，避免“先检查再插入”的竞争窗口突破上限。
  Future<bool> tryInsertFavorite(AudienceFavoritesCompanion favorite) {
    return transaction(() async {
      final existing = await (select(audienceFavorites)
            ..where((t) => t.audienceRole.equals(favorite.audienceRole.value)))
          .getSingleOrNull();
      if (existing != null) return false;

      final currentCount = await count();
      if (currentCount >= maxFavorites) return false;

      await into(audienceFavorites).insert(favorite);
      return true;
    });
  }

  /// 原子替换成员，避免替换成已存在角色导致重复。
  Future<bool> replaceFavorite(
    int oldFavoriteId,
    AudienceFavoritesCompanion favorite,
  ) {
    return transaction(() async {
      final existing = await (select(audienceFavorites)
            ..where((t) => t.audienceRole.equals(favorite.audienceRole.value)))
          .getSingleOrNull();
      if (existing != null && existing.id != oldFavoriteId) return false;

      final deleted = await (delete(audienceFavorites)
            ..where((t) => t.id.equals(oldFavoriteId)))
          .go();
      if (deleted == 0) return false;

      await into(audienceFavorites).insert(favorite);
      return true;
    });
  }

  /// 删除粉丝团成员
  Future<int> deleteFavorite(int id) {
    return (delete(audienceFavorites)..where((t) => t.id.equals(id))).go();
  }
}
