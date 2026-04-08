import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/data/database.dart';
import 'package:run_pure/data/providers.dart';
import 'package:run_pure/features/audience/domain/audience_roles.dart';
import 'package:run_pure/features/audience/domain/personalities.dart';
import 'package:run_pure/features/audience/providers.dart';
import 'package:run_pure/data/run_session_status.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> insertSession() {
    return db.into(db.runSessions).insert(
          RunSessionsCompanion.insert(
            status: const Value(RunSessionStatus.completed),
            startTime: DateTime(2026, 1, 1, 7),
            endTime: const Value(null),
            durationSeconds: 1200,
            distanceMeters: 3000,
            avgPaceSecPerKm: 400,
            bestPaceSecPerKm: 360,
          ),
        );
  }

  group('AudienceHomeNotifier', () {
    test('removeFavorite 不会把未收藏项反向切成 true', () async {
      final sessionId = await insertSession();
      final shoutId = await db.into(db.audienceShouts).insert(
            AudienceShoutsCompanion.insert(
              sessionId: sessionId,
              audienceRole: AudienceRole.screamingFan.name,
              personality: Personality.clown.name,
              triggerType: 'finish',
              content: '冲啊',
              triggerContext: '{}',
              createdAt: DateTime(2026, 1, 1, 7, 30),
              isFavorite: const Value(false),
            ),
          );

      await container.read(audienceHomeProvider.future);
      await container
          .read(audienceHomeProvider.notifier)
          .removeFavorite(shoutId, false);

      final saved = await (db.select(db.audienceShouts)
            ..where((t) => t.id.equals(shoutId)))
          .getSingle();
      expect(saved.isFavorite, isFalse);
    });

    test('并发 addFanTeam 最多只插入到 2 人', () async {
      await db.into(db.audienceFavorites).insert(
            AudienceFavoritesCompanion.insert(
              audienceRole: AudienceRole.screamingFan.name,
              personality: Personality.clown.name,
              createdAt: DateTime(2026, 1, 1, 8),
            ),
          );

      await container.read(audienceHomeProvider.future);
      final notifier = container.read(audienceHomeProvider.notifier);

      final results = await Future.wait([
        notifier.addFanTeam(AudienceRole.dataNerd, Personality.commentator),
        notifier.addFanTeam(AudienceRole.familyCrew, Personality.poet),
      ]);

      final members = await db.select(db.audienceFavorites).get();
      expect(members.length, 2);
      expect(results.where((item) => item).length, 1);
    });

    test('replaceFanTeam 不会替换成已存在角色并产生重复成员', () async {
      final firstId = await db.into(db.audienceFavorites).insert(
            AudienceFavoritesCompanion.insert(
              audienceRole: AudienceRole.screamingFan.name,
              personality: Personality.clown.name,
              createdAt: DateTime(2026, 1, 1, 8),
            ),
          );
      await db.into(db.audienceFavorites).insert(
            AudienceFavoritesCompanion.insert(
              audienceRole: AudienceRole.dataNerd.name,
              personality: Personality.commentator.name,
              createdAt: DateTime(2026, 1, 1, 9),
            ),
          );

      await container.read(audienceHomeProvider.future);
      final replaced = await container
          .read(audienceHomeProvider.notifier)
          .replaceFanTeam(
            firstId,
            AudienceRole.dataNerd,
            Personality.poet,
          );

      final members = await db.select(db.audienceFavorites).get();
      expect(replaced, isFalse);
      expect(members.length, 2);
      expect(
        members.where((item) => item.audienceRole == AudienceRole.dataNerd.name),
        hasLength(1),
      );
      expect(
        members.where((item) => item.audienceRole == AudienceRole.screamingFan.name),
        hasLength(1),
      );
    });
  });
}
