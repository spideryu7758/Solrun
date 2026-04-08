import 'package:drift/drift.dart';

import '../database.dart';

part 'training_dao.g.dart';

@DriftAccessor(tables: [TrainingPlans, TrainingDays])
class TrainingDao extends DatabaseAccessor<AppDatabase> with _$TrainingDaoMixin {
  TrainingDao(super.db);

  /// 获取所有训练计划
  Future<List<TrainingPlan>> getAllPlans() {
    return (select(trainingPlans)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// 按 ID 获取计划
  Future<TrainingPlan?> getPlanById(int id) {
    return (select(trainingPlans)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 获取计划的所有训练日
  Future<List<TrainingDay>> getDaysByPlan(int planId) {
    return (select(trainingDays)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.weekIndex),
            (t) => OrderingTerm.asc(t.dayIndex),
          ]))
        .get();
  }

  /// 插入计划
  Future<int> insertPlan(TrainingPlansCompanion plan) {
    return into(trainingPlans).insert(plan);
  }

  /// 插入训练日
  Future<void> insertDays(List<TrainingDaysCompanion> days) {
    return batch((b) => b.insertAll(trainingDays, days));
  }

  /// 删除计划（含所有训练日）
  Future<void> deletePlan(int planId) async {
    await (delete(trainingDays)..where((t) => t.planId.equals(planId))).go();
    await (delete(trainingPlans)..where((t) => t.id.equals(planId))).go();
  }

  /// 种子数据：内置训练计划
  Future<void> seedBuiltInPlans() async {
    final existing = await getAllPlans();
    if (existing.any((p) => p.isBuiltIn)) return; // 已有内置计划

    // 5km 入门计划（4 周）
    final plan5kId = await insertPlan(TrainingPlansCompanion.insert(
      name: '5km 入门',
      description: '4 周从零开��，轻松跑完 5 公里',
      totalWeeks: 4,
      isBuiltIn: const Value(true),
    ));
    await insertDays(_generate5kPlan(plan5kId));

    // 10km 进阶计划（6 周）
    final plan10kId = await insertPlan(TrainingPlansCompanion.insert(
      name: '10km 进阶',
      description: '6 周系统训练��突破 10 公里',
      totalWeeks: 6,
      isBuiltIn: const Value(true),
    ));
    await insertDays(_generate10kPlan(plan10kId));

    // 间歇跑训练（4 周）
    final intervalId = await insertPlan(TrainingPlansCompanion.insert(
      name: '间歇跑训练',
      description: '4 周间歇训练，提升配速和心肺能力',
      totalWeeks: 4,
      isBuiltIn: const Value(true),
    ));
    await insertDays(_generateIntervalPlan(intervalId));
  }

  List<TrainingDaysCompanion> _generate5kPlan(int planId) {
    final days = <TrainingDaysCompanion>[];
    // 4 周，每周 3 天（周一/三/六）
    // dayIndex 约定：1=周一, 2=周二, ..., 7=周日（与 _generate10kPlan/_generateIntervalPlan 一致）
    final weeklyDistances = [
      [2000, 2000, 3000],  // 第 1 周
      [2500, 2500, 3500],  // 第 2 周
      [3000, 3000, 4000],  // 第 3 周
      [3000, 3500, 5000],  // 第 4 周
    ];
    const dayIndices = [1, 3, 6]; // 周一=1, 周三=3, 周六=6
    for (int w = 0; w < 4; w++) {
      for (int d = 0; d < 3; d++) {
        days.add(TrainingDaysCompanion.insert(
          planId: planId,
          weekIndex: w + 1,
          dayIndex: dayIndices[d],
          type: 'easy_run',
          targetDistanceMeters: Value(weeklyDistances[w][d]),
        ));
      }
    }
    return days;
  }

  List<TrainingDaysCompanion> _generate10kPlan(int planId) {
    final days = <TrainingDaysCompanion>[];
    for (int w = 0; w < 6; w++) {
      // 周二 轻松跑
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 2,
        type: 'easy_run',
        targetDistanceMeters: Value(4000 + w * 500),
      ));
      // 周四 节奏跑
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 4,
        type: 'tempo',
        targetDistanceMeters: Value(3000 + w * 500),
        targetPaceSecPerKm: Value(330 - w * 5),
      ));
      // 周日 长距离
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 7,
        type: 'easy_run',
        targetDistanceMeters: Value(6000 + w * 1000),
      ));
    }
    return days;
  }

  List<TrainingDaysCompanion> _generateIntervalPlan(int planId) {
    final days = <TrainingDaysCompanion>[];
    for (int w = 0; w < 4; w++) {
      // 周二 间歇训练
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 2,
        type: 'interval',
        intervals: Value('{"sets":${4 + w},"runSec":${120 - w * 10},"restSec":60}'),
      ));
      // 周四 轻松恢复跑
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 4,
        type: 'easy_run',
        targetDistanceMeters: Value(3000),
      ));
      // 周六 节奏跑
      days.add(TrainingDaysCompanion.insert(
        planId: planId, weekIndex: w + 1, dayIndex: 6,
        type: 'tempo',
        targetDistanceMeters: Value(5000),
        targetPaceSecPerKm: Value(320 - w * 5),
      ));
    }
    return days;
  }
}
