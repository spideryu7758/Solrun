// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_pace_dao.dart';

// ignore_for_file: type=lint
mixin _$SplitPaceDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  $SplitPacesTable get splitPaces => attachedDatabase.splitPaces;
  SplitPaceDaoManager get managers => SplitPaceDaoManager(this);
}

class SplitPaceDaoManager {
  final _$SplitPaceDaoMixin _db;
  SplitPaceDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
  $$SplitPacesTableTableManager get splitPaces =>
      $$SplitPacesTableTableManager(_db.attachedDatabase, _db.splitPaces);
}
