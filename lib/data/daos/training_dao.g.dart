// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_dao.dart';

// ignore_for_file: type=lint
mixin _$TrainingDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingPlansTable get trainingPlans => attachedDatabase.trainingPlans;
  $TrainingDaysTable get trainingDays => attachedDatabase.trainingDays;
  TrainingDaoManager get managers => TrainingDaoManager(this);
}

class TrainingDaoManager {
  final _$TrainingDaoMixin _db;
  TrainingDaoManager(this._db);
  $$TrainingPlansTableTableManager get trainingPlans =>
      $$TrainingPlansTableTableManager(_db.attachedDatabase, _db.trainingPlans);
  $$TrainingDaysTableTableManager get trainingDays =>
      $$TrainingDaysTableTableManager(_db.attachedDatabase, _db.trainingDays);
}
