import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'run_session_status.dart';

part 'database.g.dart';

// ============================================================
// 表定义
// ============================================================

/// 跑步记录主表
class RunSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status => text().withDefault(
        const Constant(RunSessionStatus.completed),
      )(); // completed / incomplete
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer()();
  RealColumn get distanceMeters => real()();
  IntColumn get avgPaceSecPerKm => integer()();
  IntColumn get bestPaceSecPerKm => integer()();
  IntColumn get caloriesKcal => integer().withDefault(const Constant(0))();
  RealColumn get elevationGainMeters => real().withDefault(const Constant(0.0))();
  TextColumn get autoName => text().withDefault(const Constant(''))();
  TextColumn get city => text().nullable()();
  TextColumn get weather => text().nullable()();
}

/// 轨迹点表（独立于 RunSession，支持索引查询和分批写入）
class RoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(RunSessions, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get accuracy => real()();
  RealColumn get speed => real()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get orderIndex => integer()();
}

/// 分公里配速表（跑步结束时一次性写入）
class SplitPaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(RunSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get kmIndex => integer()();
  IntColumn get paceSecPerKm => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
}

/// 成就记录表
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(RunSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get achievedAt => dateTime()();
}

/// 训练计划表
class TrainingPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get totalWeeks => integer()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
}

/// 训练日定义表
class TrainingDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(TrainingPlans, #id)();
  IntColumn get weekIndex => integer()();
  IntColumn get dayIndex => integer()();
  TextColumn get type => text()(); // easy_run / tempo / interval / rest
  IntColumn get targetDistanceMeters => integer().nullable()();
  IntColumn get targetPaceSecPerKm => integer().nullable()();
  TextColumn get intervals => text().nullable()(); // 间歇定义 JSON
}

/// AI 对话消息表
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text()();     // UUID 分组对话
  TextColumn get role => text()();                // system / user / assistant
  TextColumn get content => text()();
  IntColumn get sessionId => integer().nullable()(); // 关联跑步记录（可选）
  TextColumn get summaryType => text().nullable()(); // per_run / weekly / monthly / yearly
  DateTimeColumn get createdAt => dateTime()();
}

/// 观众喊话记录表
class AudienceShouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(RunSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get audienceRole => text()();
  TextColumn get personality => text()();
  TextColumn get triggerType => text()();
  IntColumn get triggerKm => integer().nullable()();
  TextColumn get content => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get triggerContext => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 固定粉丝团表（上限 2 条）
class AudienceFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get audienceRole => text()();
  TextColumn get personality => text()();
  IntColumn get representativeShoutId =>
      integer().nullable().references(AudienceShouts, #id)();
  DateTimeColumn get createdAt => dateTime()();
}

/// 角色解锁记录表
class AudienceUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get audienceRole => text().unique()();
  DateTimeColumn get unlockedAt => dateTime()();
  IntColumn get unlockedAtRunCount => integer()();
  BoolColumn get hasSeenAnimation =>
      boolean().withDefault(const Constant(false))();
}

// ============================================================
// 数据库定义
// ============================================================

@DriftDatabase(tables: [
  RunSessions,
  RoutePoints,
  SplitPaces,
  Achievements,
  TrainingPlans,
  TrainingDays,
  ChatMessages,
  AudienceShouts,
  AudienceFavorites,
  AudienceUnlocks,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  // ── 索引定义 + 迁移 ──
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // 启用外键约束（SQLite 默认关闭）+ busy_timeout + WAL 模式
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA busy_timeout = 5000');
        await customStatement('PRAGMA journal_mode = WAL');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
        // sessionId 索引：RoutePoint 28k+ 行时避免全表扫描
        await customStatement(
          'CREATE INDEX idx_route_point_session ON route_points(session_id)',
        );
        await customStatement(
          'CREATE INDEX idx_split_pace_session ON split_paces(session_id)',
        );
        await customStatement(
          'CREATE INDEX idx_achievement_session ON achievements(session_id)',
        );
        await customStatement(
          'CREATE INDEX idx_training_day_plan ON training_days(plan_id)',
        );
        // AI 对话索引
        await customStatement(
          'CREATE INDEX idx_chat_msg_conversation ON chat_messages(conversation_id)',
        );
        // 观众系统索引
        await customStatement(
          'CREATE INDEX idx_audience_shout_session ON audience_shouts(session_id)',
        );
        await customStatement(
          'CREATE INDEX idx_audience_shout_favorite ON audience_shouts(is_favorite)',
        );
        await customStatement(
          'CREATE INDEX idx_audience_shout_role ON audience_shouts(audience_role)',
        );
        await _seedDefaultAudienceRoles();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(chatMessages);
          await customStatement(
            'CREATE INDEX idx_chat_msg_conversation ON chat_messages(conversation_id)',
          );
        }
        if (from < 3) {
          await m.createTable(audienceShouts);
          await m.createTable(audienceFavorites);
          await m.createTable(audienceUnlocks);
          // 观众系统索引
          await customStatement(
            'CREATE INDEX idx_audience_shout_session ON audience_shouts(session_id)',
          );
          await customStatement(
            'CREATE INDEX idx_audience_shout_favorite ON audience_shouts(is_favorite)',
          );
          await customStatement(
            'CREATE INDEX idx_audience_shout_role ON audience_shouts(audience_role)',
          );
          await _seedDefaultAudienceRoles();
        }
        if (from < 4) {
          // v4: RunSession 新增 city 和 weather 字段
          await customStatement(
            'ALTER TABLE run_sessions ADD COLUMN city TEXT',
          );
          await customStatement(
            'ALTER TABLE run_sessions ADD COLUMN weather TEXT',
          );
        }
      },
    );
  }

  /// 插入 4 个默认解锁角色的种子数据（insertOrIgnore 防止重复插入）
  Future<void> _seedDefaultAudienceRoles() async {
    final now = DateTime.now();
    for (final role in ['screamingFan', 'dataNerd', 'familyCrew', 'zenViewer']) {
      await into(audienceUnlocks).insert(
        AudienceUnlocksCompanion.insert(
          audienceRole: role,
          unlockedAt: now,
          unlockedAtRunCount: 0,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'runpure.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
