// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audience_shout_dao.dart';

// ignore_for_file: type=lint
mixin _$AudienceShoutDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  $AudienceShoutsTable get audienceShouts => attachedDatabase.audienceShouts;
  AudienceShoutDaoManager get managers => AudienceShoutDaoManager(this);
}

class AudienceShoutDaoManager {
  final _$AudienceShoutDaoMixin _db;
  AudienceShoutDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
  $$AudienceShoutsTableTableManager get audienceShouts =>
      $$AudienceShoutsTableTableManager(
        _db.attachedDatabase,
        _db.audienceShouts,
      );
}
