// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_dao.dart';

// ignore_for_file: type=lint
mixin _$RoutePointDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunSessionsTable get runSessions => attachedDatabase.runSessions;
  $RoutePointsTable get routePoints => attachedDatabase.routePoints;
  RoutePointDaoManager get managers => RoutePointDaoManager(this);
}

class RoutePointDaoManager {
  final _$RoutePointDaoMixin _db;
  RoutePointDaoManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db.attachedDatabase, _db.runSessions);
  $$RoutePointsTableTableManager get routePoints =>
      $$RoutePointsTableTableManager(_db.attachedDatabase, _db.routePoints);
}
