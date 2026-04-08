import 'audience_roles.dart';

/// 解锁条件检查器（纯 domain 逻辑，不依赖 data 层）
///
/// 判断哪些角色应该被解锁，由调用方负责持久化写入。
class UnlockChecker {
  UnlockChecker._();

  /// 检查并返回满足解锁条件但尚未解锁的角色列表
  ///
  /// [totalRunCount] 已完成的跑步总次数
  /// [alreadyUnlockedNames] 已解锁角色的 name 集合
  static List<AudienceRole> check({
    required int totalRunCount,
    required Set<String> alreadyUnlockedNames,
  }) {
    return [
      for (final role in AudienceRole.values)
        if (!role.isDefaultUnlocked &&
            totalRunCount >= role.unlockThreshold &&
            !alreadyUnlockedNames.contains(role.name))
          role,
    ];
  }
}
