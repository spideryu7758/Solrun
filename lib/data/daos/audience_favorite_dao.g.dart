// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audience_favorite_dao.dart';

// ignore_for_file: type=lint
mixin _$AudienceFavoriteDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  $AudienceShoutsTable get audienceShouts => attachedDatabase.audienceShouts;
  $AudienceFavoritesTable get audienceFavorites =>
      attachedDatabase.audienceFavorites;
  AudienceFavoriteDaoManager get managers => AudienceFavoriteDaoManager(this);
}

class AudienceFavoriteDaoManager {
  final _$AudienceFavoriteDaoMixin _db;
  AudienceFavoriteDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
  $$AudienceShoutsTableTableManager get audienceShouts =>
      $$AudienceShoutsTableTableManager(
        _db.attachedDatabase,
        _db.audienceShouts,
      );
  $$AudienceFavoritesTableTableManager get audienceFavorites =>
      $$AudienceFavoritesTableTableManager(
        _db.attachedDatabase,
        _db.audienceFavorites,
      );
}
