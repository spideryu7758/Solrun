import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/audience/domain/audience_roles.dart';
import 'package:run_pure/features/audience/domain/unlock_checker.dart';

void main() {
  group('UnlockChecker', () {
    test('0 次跑步，无已解锁 → 返回空列表（初始角色由 DB 种子数据处理）', () {
      final result = UnlockChecker.check(
        totalRunCount: 0,
        alreadyUnlockedNames: {},
      );
      // 初始角色的 unlockThreshold = 0 且 isDefaultUnlocked = true
      // check 方法过滤掉 isDefaultUnlocked 的角色，所以 0 次跑步也不返回初始角色
      expect(result, isEmpty);
    });

    test('5 次跑步 → 无新解锁（gambler 需要 10 次）', () {
      final result = UnlockChecker.check(
        totalRunCount: 5,
        alreadyUnlockedNames: {},
      );
      expect(result, isEmpty);
    });

    test('10 次跑步 → 解锁 gambler', () {
      final result = UnlockChecker.check(
        totalRunCount: 10,
        alreadyUnlockedNames: {},
      );
      expect(result, contains(AudienceRole.gambler));
      expect(result.length, equals(1));
    });

    test('20 次跑步 → 解锁 gambler + nitpicker', () {
      final result = UnlockChecker.check(
        totalRunCount: 20,
        alreadyUnlockedNames: {},
      );
      expect(result, contains(AudienceRole.gambler));
      expect(result, contains(AudienceRole.nitpicker));
      expect(result.length, equals(2));
    });

    test('30 次跑步 → 解锁 gambler + nitpicker + rivalFan', () {
      final result = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: {},
      );
      expect(result, contains(AudienceRole.gambler));
      expect(result, contains(AudienceRole.nitpicker));
      expect(result, contains(AudienceRole.rivalFan));
      expect(result.length, equals(3));
    });

    test('100 次跑步 → 仍然只返回 3 个可解锁角色', () {
      final result = UnlockChecker.check(
        totalRunCount: 100,
        alreadyUnlockedNames: {},
      );
      expect(result.length, equals(3));
    });

    test('已解锁 gambler → 不重复返回', () {
      final result = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: {'gambler'},
      );
      expect(result, isNot(contains(AudienceRole.gambler)));
      expect(result, contains(AudienceRole.nitpicker));
      expect(result, contains(AudienceRole.rivalFan));
      expect(result.length, equals(2));
    });

    test('全部已解锁 → 返回空列表', () {
      final result = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: {'gambler', 'nitpicker', 'rivalFan'},
      );
      expect(result, isEmpty);
    });

    test('初始角色即使在 alreadyUnlockedNames 中也不返回', () {
      final result = UnlockChecker.check(
        totalRunCount: 30,
        alreadyUnlockedNames: {
          'screamingFan',
          'dataNerd',
          'familyCrew',
          'zenViewer',
        },
      );
      // 初始角色被 isDefaultUnlocked 过滤，不受 alreadyUnlockedNames 影响
      expect(result, contains(AudienceRole.gambler));
      expect(result, contains(AudienceRole.nitpicker));
      expect(result, contains(AudienceRole.rivalFan));
    });

    test('恰好达到阈值时解锁（边界值）', () {
      // gambler 阈值 10
      final at9 = UnlockChecker.check(
        totalRunCount: 9,
        alreadyUnlockedNames: {},
      );
      expect(at9, isEmpty);

      final at10 = UnlockChecker.check(
        totalRunCount: 10,
        alreadyUnlockedNames: {},
      );
      expect(at10, contains(AudienceRole.gambler));
    });
  });
}
