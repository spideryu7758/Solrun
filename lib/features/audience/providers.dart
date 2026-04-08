import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/services/tts_service.dart';
import '../tracking/presentation/tracking_state.dart';
import '../tracking/providers.dart';
import 'data/audience_engine.dart';
import 'domain/audience_roles.dart';
import 'domain/personalities.dart';
import 'presentation/audience_home_notifier.dart';
import 'presentation/audience_shout_notifier.dart';
import 'presentation/interview_notifier.dart';
import 'presentation/interview_state.dart';

// 观众系统 DAO Providers 已统一定义在 data/providers.dart，此处重新导出以兼容现有引用
export '../../data/providers.dart'
    show audienceShoutDaoProvider, audienceFavoriteDaoProvider, audienceUnlockDaoProvider;

// ── 引擎 ──

/// 观众引擎单例（注入 DAO 实例，避免引擎内部重复创建）
final audienceEngineProvider = Provider<AudienceEngine>((ref) {
  return AudienceEngine(
    ref,
    shoutDao: ref.read(audienceShoutDaoProvider),
    favoriteDao: ref.read(audienceFavoriteDaoProvider),
    unlockDao: ref.read(audienceUnlockDaoProvider),
  );
});

// ── 观众喊话 Notifier（零侵入：通过 ref.listen 监听 trackingProvider） ──

final audienceShoutProvider =
    StateNotifierProvider<AudienceShoutNotifier, AudienceShoutState>((ref) {
  final tts = ref.read(ttsServiceProvider);
  final notifier = AudienceShoutNotifier(ref, tts);

  // 监听 tracking 状态变化，触发观众喊话逻辑
  ref.listen<TrackingState>(trackingProvider, (prev, next) {
    notifier.onTrackingStateUpdate(
      prev ?? const TrackingState(),
      next,
    );
  });

  return notifier;
});

// ── 已解锁角色集合 ──

/// 获取所有已解锁角色代号
final unlockedRolesProvider = FutureProvider<Set<String>>((ref) async {
  final dao = ref.read(audienceUnlockDaoProvider);
  final roles = await dao.getUnlockedRoles();
  return roles.toSet();
});

/// 获取已解锁的 AudienceRole 枚举集合
final unlockedAudienceRolesProvider =
    FutureProvider<Set<AudienceRole>>((ref) async {
  final roleNames = await ref.watch(unlockedRolesProvider.future);
  return roleNames.map((name) => AudienceRole.fromName(name)).toSet();
});

// ── 观众席主页 ──

final audienceHomeProvider =
    AsyncNotifierProvider<AudienceHomeNotifier, AudienceHomeState>(
  AudienceHomeNotifier.new,
);

final roleRecentShoutsProvider =
    FutureProvider.family<List<AudienceShout>, String>((ref, roleName) {
  return ref.read(audienceShoutDaoProvider).getRecentByRole(roleName, limit: 20);
});

// ── 赛后采访 ──

/// 采访参数（用于生成 family provider 的 key）
typedef InterviewArgs = ({
  int sessionId,
  AudienceRole role,
  Personality personality,
});

/// 赛后采访 Provider（按 sessionId+role+personality 隔离）
final interviewProvider = StateNotifierProvider.autoDispose
    .family<InterviewNotifier, InterviewState, InterviewArgs>((ref, args) {
  return InterviewNotifier(ref, args.sessionId, args.role, args.personality);
});

// ── 结果页用 Provider ──

/// 本场观众喊话 Provider
final sessionShoutsProvider = FutureProvider.family<List<AudienceShout>, int>((ref, id) {
  return ref.read(audienceShoutDaoProvider).getBySession(id);
});
