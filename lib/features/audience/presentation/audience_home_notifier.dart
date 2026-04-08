import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';

/// 观众席主页状态
class AudienceHomeState {
  final List<AudienceShout> favorites;
  final List<AudienceFavorite> fanTeam;
  final List<AudienceUnlock> unlocks;
  final Map<String, int> roleCounts;
  final int totalRunCount;

  const AudienceHomeState({
    this.favorites = const [],
    this.fanTeam = const [],
    this.unlocks = const [],
    this.roleCounts = const {},
    this.totalRunCount = 0,
  });

  /// 已解锁的角色名集合
  Set<String> get unlockedRoleNames =>
      unlocks.map((u) => u.audienceRole).toSet();

  /// 判断角色是否已解锁
  bool isRoleUnlocked(AudienceRole role) =>
      unlockedRoleNames.contains(role.name);

  /// 计算距离解锁还差多少次
  int runsToUnlock(AudienceRole role) {
    if (isRoleUnlocked(role)) return 0;
    final threshold = role.unlockThreshold;
    return (threshold - totalRunCount).clamp(0, threshold);
  }

  AudienceHomeState copyWith({
    List<AudienceShout>? favorites,
    List<AudienceFavorite>? fanTeam,
    List<AudienceUnlock>? unlocks,
    Map<String, int>? roleCounts,
    int? totalRunCount,
  }) {
    return AudienceHomeState(
      favorites: favorites ?? this.favorites,
      fanTeam: fanTeam ?? this.fanTeam,
      unlocks: unlocks ?? this.unlocks,
      roleCounts: roleCounts ?? this.roleCounts,
      totalRunCount: totalRunCount ?? this.totalRunCount,
    );
  }
}

/// 观众席主页状态管理
class AudienceHomeNotifier extends AsyncNotifier<AudienceHomeState> {
  @override
  Future<AudienceHomeState> build() async {
    return _loadAll();
  }

  Future<AudienceHomeState> _loadAll() async {
    final shoutDao = ref.read(audienceShoutDaoProvider);
    final favDao = ref.read(audienceFavoriteDaoProvider);
    final unlockDao = ref.read(audienceUnlockDaoProvider);
    final sessionDao = ref.read(runSessionDaoProvider);

    try {
      final results = await Future.wait([
        shoutDao.getFavorites(),
        favDao.getAll(),
        unlockDao.getAll(),
        shoutDao.countByRole(),
        sessionDao.getTotalCount(),
      ]).timeout(const Duration(seconds: 10));

      return AudienceHomeState(
        favorites: results[0] as List<AudienceShout>,
        fanTeam: results[1] as List<AudienceFavorite>,
        unlocks: results[2] as List<AudienceUnlock>,
        roleCounts: results[3] as Map<String, int>,
        totalRunCount: results[4] as int,
      );
    } on TimeoutException {
      // 数据库查询超时，返回空状态而非无限等待
      throw Exception('观众席数据加载超时');
    }
  }

  /// 刷新所有数据
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadAll());
  }

  /// 取消收藏（金句墙左滑删除）— 乐观更新，不重新加载全部数据
  Future<void> removeFavorite(int shoutId, bool currentValue) async {
    if (!currentValue) return;

    // 乐观更新：立即从本地 state 移除
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        favorites: current.favorites
            .where((s) => s.id != shoutId)
            .toList(),
      ));
    }

    // 异步持久化到数据库
    try {
      final dao = ref.read(audienceShoutDaoProvider);
      await dao.setFavorite(shoutId, false);
    } on Exception {
      // 数据库写入失败，回滚到全量刷新以恢复一致性
      await refresh();
    }
  }

  /// 添加粉丝团成员
  Future<bool> addFanTeam(AudienceRole role, Personality personality,
      {int? representativeShoutId}) async {
    final favDao = ref.read(audienceFavoriteDaoProvider);
    final inserted = await favDao.tryInsertFavorite(AudienceFavoritesCompanion.insert(
      audienceRole: role.name,
      personality: personality.name,
      representativeShoutId: representativeShoutId != null
          ? Value(representativeShoutId)
          : const Value.absent(),
      createdAt: DateTime.now(),
    ));
    if (!inserted) return false;
    await refresh();
    return true;
  }

  /// 移除粉丝团成员 — 乐观更新，不重新加载全部数据
  Future<void> removeFanTeam(int favoriteId) async {
    // 乐观更新：立即从本地 state 移除
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        fanTeam: current.fanTeam
            .where((f) => f.id != favoriteId)
            .toList(),
      ));
    }

    // 异步持久化到数据库
    try {
      final favDao = ref.read(audienceFavoriteDaoProvider);
      await favDao.deleteFavorite(favoriteId);
    } on Exception {
      // 数据库写入失败，回滚到全量刷新以恢复一致性
      await refresh();
    }
  }

  /// 替换粉丝团成员
  Future<bool> replaceFanTeam(
    int oldFavoriteId,
    AudienceRole newRole,
    Personality newPersonality, {
    int? representativeShoutId,
  }) async {
    final favDao = ref.read(audienceFavoriteDaoProvider);
    final replaced = await favDao.replaceFavorite(
      oldFavoriteId,
      AudienceFavoritesCompanion.insert(
        audienceRole: newRole.name,
        personality: newPersonality.name,
        representativeShoutId: representativeShoutId != null
            ? Value(representativeShoutId)
            : const Value.absent(),
        createdAt: DateTime.now(),
      ),
    );
    if (!replaced) return false;
    await refresh();
    return true;
  }
}
