// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_dao.dart';

// ignore_for_file: type=lint
mixin _$AchievementDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  $AchievementsTable get achievements => attachedDatabase.achievements;
  AchievementDaoManager get managers => AchievementDaoManager(this);
}

class AchievementDaoManager {
  final _$AchievementDaoMixin _db;
  AchievementDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db.attachedDatabase, _db.achievements);
}
