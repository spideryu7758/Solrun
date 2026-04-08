// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_session_dao.dart';

// ignore_for_file: type=lint
mixin _$RunSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  RunSessionDaoManager get managers => RunSessionDaoManager(this);
}

class RunSessionDaoManager {
  final _$RunSessionDaoMixin _db;
  RunSessionDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
}
