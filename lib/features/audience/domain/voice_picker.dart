import 'dart:math';

import 'audience_roles.dart';
import 'personalities.dart';
import 'mood_states.dart';

/// 角色组合：一次观众喊话由「角色 × 人格」组合决定
class VoiceCombo {
  final AudienceRole role;
  final Personality personality;

  const VoiceCombo({required this.role, required this.personality});

  @override
  bool operator ==(Object other) =>
      other is VoiceCombo && other.role == role && other.personality == personality;

  @override
  int get hashCode => Object.hash(role, personality);

  @override
  String toString() => '${role.displayName}·${personality.displayName}';
}

/// 角色组合随机抽取算法（设计文档 3.2 节）
class VoicePicker {
  VoicePicker._();

  /// 防重复队列大小
  static const _historySize = 5;

  /// 防重复队列（最近的组合，尾部最新）
  /// 生命周期：静态全局变量，跨实例共享。
  /// 每次新跑步开始时由 AudienceShoutNotifier 调用 resetHistory() 清空，
  /// 确保不会跨跑步累积历史。
  static final List<VoiceCombo> _recentHistory = [];

  /// 加权随机抽取一个角色组合
  ///
  /// [mood] 跑前选择的状态，影响权重
  /// [unlockedRoles] 当前已解锁的角色集合
  /// [fanTeamRoles] 固定粉丝团角色集合（权重 ×1.5）
  static VoiceCombo pickRandomVoice({
    required MoodState mood,
    required Set<AudienceRole> unlockedRoles,
    required Set<AudienceRole> fanTeamRoles,
  }) {
    final roleWeights = mood.roleWeights();
    final personalityWeights = mood.personalityWeights();

    // 过滤未解锁角色
    final availableRoles = AudienceRole.values
        .where((r) => unlockedRoles.contains(r))
        .toList();

    // 生成所有可用组合
    final combos = <VoiceCombo>[];
    final weights = <double>[];

    for (final role in availableRoles) {
      // 粉丝团角色权重 ×1.5
      final roleMultiplier = fanTeamRoles.contains(role) ? 1.5 : 1.0;
      final baseRoleWeight = roleWeights[role] ?? 1.0;

      for (final personality in Personality.values) {
        final combo = VoiceCombo(role: role, personality: personality);
        final basePersonalityWeight = personalityWeights[personality] ?? 1.0;
        final totalWeight = baseRoleWeight * roleMultiplier * basePersonalityWeight;
        combos.add(combo);
        weights.add(totalWeight);
      }
    }

    if (combos.isEmpty) {
      // 降级：返回默认组合
      return const VoiceCombo(
        role: AudienceRole.screamingFan,
        personality: Personality.hypeCoach,
      );
    }

    // 检查防重复约束是否可满足
    final nonRecent = <int>[];
    for (int i = 0; i < combos.length; i++) {
      if (!_recentHistory.contains(combos[i])) {
        nonRecent.add(i);
      }
    }

    // 可用组合 ≤ 防重复队列大小时，放宽限制
    final useAntiRepeat = nonRecent.length > _historySize;
    final candidateIndices = useAntiRepeat ? nonRecent : List.generate(combos.length, (i) => i);

    // 加权随机选择
    final candidateWeights = candidateIndices.map((i) => weights[i]).toList();
    final selectedIndex = _weightedRandom(candidateWeights);
    final chosen = combos[candidateIndices[selectedIndex]];

    // 更新防重复队列
    _recentHistory.add(chosen);
    if (_recentHistory.length > _historySize) {
      _recentHistory.removeAt(0);
    }

    return chosen;
  }

  /// 加权随机选择索引
  static int _weightedRandom(List<double> weights) {
    final total = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return Random().nextInt(weights.length);

    final r = Random().nextDouble() * total;
    double cumulative = 0;
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (r <= cumulative) return i;
    }
    return weights.length - 1;
  }

  /// 清除防重复队列（新跑步开始时调用）
  static void resetHistory() {
    _recentHistory.clear();
  }
}
