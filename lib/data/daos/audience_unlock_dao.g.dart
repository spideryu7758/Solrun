// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audience_unlock_dao.dart';

// ignore_for_file: type=lint
mixin _$AudienceUnlockDaoMixin on DatabaseAccessor<AppDatabase> {
  $AudienceUnlocksTable get audienceUnlocks => attachedDatabase.audienceUnlocks;
  AudienceUnlockDaoManager get managers => AudienceUnlockDaoManager(this);
}

class AudienceUnlockDaoManager {
  final _$AudienceUnlockDaoMixin _db;
  AudienceUnlockDaoManager(this._db);
  $$AudienceUnlocksTableTableManager get audienceUnlocks =>
      $$AudienceUnlocksTableTableManager(
        _db.attachedDatabase,
        _db.audienceUnlocks,
      );
}
