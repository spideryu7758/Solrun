// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RunSessionsTable extends RunSessions
    with TableInfo<$RunSessionsTable, RunSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RunSessionStatus.completed),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgPaceSecPerKmMeta = const VerificationMeta(
    'avgPaceSecPerKm',
  );
  @override
  late final GeneratedColumn<int> avgPaceSecPerKm = GeneratedColumn<int>(
    'avg_pace_sec_per_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestPaceSecPerKmMeta = const VerificationMeta(
    'bestPaceSecPerKm',
  );
  @override
  late final GeneratedColumn<int> bestPaceSecPerKm = GeneratedColumn<int>(
    'best_pace_sec_per_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<int> caloriesKcal = GeneratedColumn<int>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _autoNameMeta = const VerificationMeta(
    'autoName',
  );
  @override
  late final GeneratedColumn<String> autoName = GeneratedColumn<String>(
    'auto_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    startTime,
    endTime,
    durationSeconds,
    distanceMeters,
    avgPaceSecPerKm,
    bestPaceSecPerKm,
    caloriesKcal,
    elevationGainMeters,
    autoName,
    city,
    weather,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('avg_pace_sec_per_km')) {
      context.handle(
        _avgPaceSecPerKmMeta,
        avgPaceSecPerKm.isAcceptableOrUnknown(
          data['avg_pace_sec_per_km']!,
          _avgPaceSecPerKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgPaceSecPerKmMeta);
    }
    if (data.containsKey('best_pace_sec_per_km')) {
      context.handle(
        _bestPaceSecPerKmMeta,
        bestPaceSecPerKm.isAcceptableOrUnknown(
          data['best_pace_sec_per_km']!,
          _bestPaceSecPerKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bestPaceSecPerKmMeta);
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('auto_name')) {
      context.handle(
        _autoNameMeta,
        autoName.isAcceptableOrUnknown(data['auto_name']!, _autoNameMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      avgPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_pace_sec_per_km'],
      )!,
      bestPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_pace_sec_per_km'],
      )!,
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_kcal'],
      )!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      )!,
      autoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
    );
  }

  @override
  $RunSessionsTable createAlias(String alias) {
    return $RunSessionsTable(attachedDatabase, alias);
  }
}

class RunSession extends DataClass implements Insertable<RunSession> {
  final int id;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double distanceMeters;
  final int avgPaceSecPerKm;
  final int bestPaceSecPerKm;
  final int caloriesKcal;
  final double elevationGainMeters;
  final String autoName;
  final String? city;
  final String? weather;
  const RunSession({
    required this.id,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.avgPaceSecPerKm,
    required this.bestPaceSecPerKm,
    required this.caloriesKcal,
    required this.elevationGainMeters,
    required this.autoName,
    this.city,
    this.weather,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['avg_pace_sec_per_km'] = Variable<int>(avgPaceSecPerKm);
    map['best_pace_sec_per_km'] = Variable<int>(bestPaceSecPerKm);
    map['calories_kcal'] = Variable<int>(caloriesKcal);
    map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    map['auto_name'] = Variable<String>(autoName);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    return map;
  }

  RunSessionsCompanion toCompanion(bool nullToAbsent) {
    return RunSessionsCompanion(
      id: Value(id),
      status: Value(status),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: Value(durationSeconds),
      distanceMeters: Value(distanceMeters),
      avgPaceSecPerKm: Value(avgPaceSecPerKm),
      bestPaceSecPerKm: Value(bestPaceSecPerKm),
      caloriesKcal: Value(caloriesKcal),
      elevationGainMeters: Value(elevationGainMeters),
      autoName: Value(autoName),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
    );
  }

  factory RunSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunSession(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      avgPaceSecPerKm: serializer.fromJson<int>(json['avgPaceSecPerKm']),
      bestPaceSecPerKm: serializer.fromJson<int>(json['bestPaceSecPerKm']),
      caloriesKcal: serializer.fromJson<int>(json['caloriesKcal']),
      elevationGainMeters: serializer.fromJson<double>(
        json['elevationGainMeters'],
      ),
      autoName: serializer.fromJson<String>(json['autoName']),
      city: serializer.fromJson<String?>(json['city']),
      weather: serializer.fromJson<String?>(json['weather']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'avgPaceSecPerKm': serializer.toJson<int>(avgPaceSecPerKm),
      'bestPaceSecPerKm': serializer.toJson<int>(bestPaceSecPerKm),
      'caloriesKcal': serializer.toJson<int>(caloriesKcal),
      'elevationGainMeters': serializer.toJson<double>(elevationGainMeters),
      'autoName': serializer.toJson<String>(autoName),
      'city': serializer.toJson<String?>(city),
      'weather': serializer.toJson<String?>(weather),
    };
  }

  RunSession copyWith({
    int? id,
    String? status,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? durationSeconds,
    double? distanceMeters,
    int? avgPaceSecPerKm,
    int? bestPaceSecPerKm,
    int? caloriesKcal,
    double? elevationGainMeters,
    String? autoName,
    Value<String?> city = const Value.absent(),
    Value<String?> weather = const Value.absent(),
  }) => RunSession(
    id: id ?? this.id,
    status: status ?? this.status,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    avgPaceSecPerKm: avgPaceSecPerKm ?? this.avgPaceSecPerKm,
    bestPaceSecPerKm: bestPaceSecPerKm ?? this.bestPaceSecPerKm,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
    autoName: autoName ?? this.autoName,
    city: city.present ? city.value : this.city,
    weather: weather.present ? weather.value : this.weather,
  );
  RunSession copyWithCompanion(RunSessionsCompanion data) {
    return RunSession(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      avgPaceSecPerKm: data.avgPaceSecPerKm.present
          ? data.avgPaceSecPerKm.value
          : this.avgPaceSecPerKm,
      bestPaceSecPerKm: data.bestPaceSecPerKm.present
          ? data.bestPaceSecPerKm.value
          : this.bestPaceSecPerKm,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      autoName: data.autoName.present ? data.autoName.value : this.autoName,
      city: data.city.present ? data.city.value : this.city,
      weather: data.weather.present ? data.weather.value : this.weather,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunSession(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('avgPaceSecPerKm: $avgPaceSecPerKm, ')
          ..write('bestPaceSecPerKm: $bestPaceSecPerKm, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('autoName: $autoName, ')
          ..write('city: $city, ')
          ..write('weather: $weather')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    startTime,
    endTime,
    durationSeconds,
    distanceMeters,
    avgPaceSecPerKm,
    bestPaceSecPerKm,
    caloriesKcal,
    elevationGainMeters,
    autoName,
    city,
    weather,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunSession &&
          other.id == this.id &&
          other.status == this.status &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.avgPaceSecPerKm == this.avgPaceSecPerKm &&
          other.bestPaceSecPerKm == this.bestPaceSecPerKm &&
          other.caloriesKcal == this.caloriesKcal &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.autoName == this.autoName &&
          other.city == this.city &&
          other.weather == this.weather);
}

class RunSessionsCompanion extends UpdateCompanion<RunSession> {
  final Value<int> id;
  final Value<String> status;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> durationSeconds;
  final Value<double> distanceMeters;
  final Value<int> avgPaceSecPerKm;
  final Value<int> bestPaceSecPerKm;
  final Value<int> caloriesKcal;
  final Value<double> elevationGainMeters;
  final Value<String> autoName;
  final Value<String?> city;
  final Value<String?> weather;
  const RunSessionsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.avgPaceSecPerKm = const Value.absent(),
    this.bestPaceSecPerKm = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.autoName = const Value.absent(),
    this.city = const Value.absent(),
    this.weather = const Value.absent(),
  });
  RunSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required int durationSeconds,
    required double distanceMeters,
    required int avgPaceSecPerKm,
    required int bestPaceSecPerKm,
    this.caloriesKcal = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.autoName = const Value.absent(),
    this.city = const Value.absent(),
    this.weather = const Value.absent(),
  }) : startTime = Value(startTime),
       durationSeconds = Value(durationSeconds),
       distanceMeters = Value(distanceMeters),
       avgPaceSecPerKm = Value(avgPaceSecPerKm),
       bestPaceSecPerKm = Value(bestPaceSecPerKm);
  static Insertable<RunSession> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
    Expression<int>? avgPaceSecPerKm,
    Expression<int>? bestPaceSecPerKm,
    Expression<int>? caloriesKcal,
    Expression<double>? elevationGainMeters,
    Expression<String>? autoName,
    Expression<String>? city,
    Expression<String>? weather,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (avgPaceSecPerKm != null) 'avg_pace_sec_per_km': avgPaceSecPerKm,
      if (bestPaceSecPerKm != null) 'best_pace_sec_per_km': bestPaceSecPerKm,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (autoName != null) 'auto_name': autoName,
      if (city != null) 'city': city,
      if (weather != null) 'weather': weather,
    });
  }

  RunSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? status,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? durationSeconds,
    Value<double>? distanceMeters,
    Value<int>? avgPaceSecPerKm,
    Value<int>? bestPaceSecPerKm,
    Value<int>? caloriesKcal,
    Value<double>? elevationGainMeters,
    Value<String>? autoName,
    Value<String?>? city,
    Value<String?>? weather,
  }) {
    return RunSessionsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      avgPaceSecPerKm: avgPaceSecPerKm ?? this.avgPaceSecPerKm,
      bestPaceSecPerKm: bestPaceSecPerKm ?? this.bestPaceSecPerKm,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      autoName: autoName ?? this.autoName,
      city: city ?? this.city,
      weather: weather ?? this.weather,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (avgPaceSecPerKm.present) {
      map['avg_pace_sec_per_km'] = Variable<int>(avgPaceSecPerKm.value);
    }
    if (bestPaceSecPerKm.present) {
      map['best_pace_sec_per_km'] = Variable<int>(bestPaceSecPerKm.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<int>(caloriesKcal.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (autoName.present) {
      map['auto_name'] = Variable<String>(autoName.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunSessionsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('avgPaceSecPerKm: $avgPaceSecPerKm, ')
          ..write('bestPaceSecPerKm: $bestPaceSecPerKm, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('autoName: $autoName, ')
          ..write('city: $city, ')
          ..write('weather: $weather')
          ..write(')'))
        .toString();
  }
}

class $RoutePointsTable extends RoutePoints
    with TableInfo<$RoutePointsTable, RoutePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id)',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    latitude,
    longitude,
    altitude,
    accuracy,
    speed,
    timestamp,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutePoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutePoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $RoutePointsTable createAlias(String alias) {
    return $RoutePointsTable(attachedDatabase, alias);
  }
}

class RoutePoint extends DataClass implements Insertable<RoutePoint> {
  final int id;
  final int sessionId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final double speed;
  final DateTime timestamp;
  final int orderIndex;
  const RoutePoint({
    required this.id,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['accuracy'] = Variable<double>(accuracy);
    map['speed'] = Variable<double>(speed);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  RoutePointsCompanion toCompanion(bool nullToAbsent) {
    return RoutePointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      accuracy: Value(accuracy),
      speed: Value(speed),
      timestamp: Value(timestamp),
      orderIndex: Value(orderIndex),
    );
  }

  factory RoutePoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutePoint(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      speed: serializer.fromJson<double>(json['speed']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'accuracy': serializer.toJson<double>(accuracy),
      'speed': serializer.toJson<double>(speed),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  RoutePoint copyWith({
    int? id,
    int? sessionId,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    double? accuracy,
    double? speed,
    DateTime? timestamp,
    int? orderIndex,
  }) => RoutePoint(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    accuracy: accuracy ?? this.accuracy,
    speed: speed ?? this.speed,
    timestamp: timestamp ?? this.timestamp,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  RoutePoint copyWithCompanion(RoutePointsCompanion data) {
    return RoutePoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutePoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    latitude,
    longitude,
    altitude,
    accuracy,
    speed,
    timestamp,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.speed == this.speed &&
          other.timestamp == this.timestamp &&
          other.orderIndex == this.orderIndex);
}

class RoutePointsCompanion extends UpdateCompanion<RoutePoint> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double> accuracy;
  final Value<double> speed;
  final Value<DateTime> timestamp;
  final Value<int> orderIndex;
  const RoutePointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  RoutePointsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    required double accuracy,
    required double speed,
    required DateTime timestamp,
    required int orderIndex,
  }) : sessionId = Value(sessionId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       accuracy = Value(accuracy),
       speed = Value(speed),
       timestamp = Value(timestamp),
       orderIndex = Value(orderIndex);
  static Insertable<RoutePoint> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<double>? speed,
    Expression<DateTime>? timestamp,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (timestamp != null) 'timestamp': timestamp,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  RoutePointsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double>? accuracy,
    Value<double>? speed,
    Value<DateTime>? timestamp,
    Value<int>? orderIndex,
  }) {
    return RoutePointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $SplitPacesTable extends SplitPaces
    with TableInfo<$SplitPacesTable, SplitPace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitPacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id)',
    ),
  );
  static const VerificationMeta _kmIndexMeta = const VerificationMeta(
    'kmIndex',
  );
  @override
  late final GeneratedColumn<int> kmIndex = GeneratedColumn<int>(
    'km_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceSecPerKmMeta = const VerificationMeta(
    'paceSecPerKm',
  );
  @override
  late final GeneratedColumn<int> paceSecPerKm = GeneratedColumn<int>(
    'pace_sec_per_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    kmIndex,
    paceSecPerKm,
    startTime,
    endTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_paces';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitPace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('km_index')) {
      context.handle(
        _kmIndexMeta,
        kmIndex.isAcceptableOrUnknown(data['km_index']!, _kmIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_kmIndexMeta);
    }
    if (data.containsKey('pace_sec_per_km')) {
      context.handle(
        _paceSecPerKmMeta,
        paceSecPerKm.isAcceptableOrUnknown(
          data['pace_sec_per_km']!,
          _paceSecPerKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paceSecPerKmMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitPace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitPace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      kmIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km_index'],
      )!,
      paceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pace_sec_per_km'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
    );
  }

  @override
  $SplitPacesTable createAlias(String alias) {
    return $SplitPacesTable(attachedDatabase, alias);
  }
}

class SplitPace extends DataClass implements Insertable<SplitPace> {
  final int id;
  final int sessionId;
  final int kmIndex;
  final int paceSecPerKm;
  final DateTime startTime;
  final DateTime endTime;
  const SplitPace({
    required this.id,
    required this.sessionId,
    required this.kmIndex,
    required this.paceSecPerKm,
    required this.startTime,
    required this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['km_index'] = Variable<int>(kmIndex);
    map['pace_sec_per_km'] = Variable<int>(paceSecPerKm);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    return map;
  }

  SplitPacesCompanion toCompanion(bool nullToAbsent) {
    return SplitPacesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      kmIndex: Value(kmIndex),
      paceSecPerKm: Value(paceSecPerKm),
      startTime: Value(startTime),
      endTime: Value(endTime),
    );
  }

  factory SplitPace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitPace(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      kmIndex: serializer.fromJson<int>(json['kmIndex']),
      paceSecPerKm: serializer.fromJson<int>(json['paceSecPerKm']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'kmIndex': serializer.toJson<int>(kmIndex),
      'paceSecPerKm': serializer.toJson<int>(paceSecPerKm),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
    };
  }

  SplitPace copyWith({
    int? id,
    int? sessionId,
    int? kmIndex,
    int? paceSecPerKm,
    DateTime? startTime,
    DateTime? endTime,
  }) => SplitPace(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    kmIndex: kmIndex ?? this.kmIndex,
    paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
  );
  SplitPace copyWithCompanion(SplitPacesCompanion data) {
    return SplitPace(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      kmIndex: data.kmIndex.present ? data.kmIndex.value : this.kmIndex,
      paceSecPerKm: data.paceSecPerKm.present
          ? data.paceSecPerKm.value
          : this.paceSecPerKm,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitPace(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kmIndex: $kmIndex, ')
          ..write('paceSecPerKm: $paceSecPerKm, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, kmIndex, paceSecPerKm, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitPace &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.kmIndex == this.kmIndex &&
          other.paceSecPerKm == this.paceSecPerKm &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class SplitPacesCompanion extends UpdateCompanion<SplitPace> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> kmIndex;
  final Value<int> paceSecPerKm;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  const SplitPacesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.kmIndex = const Value.absent(),
    this.paceSecPerKm = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
  });
  SplitPacesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int kmIndex,
    required int paceSecPerKm,
    required DateTime startTime,
    required DateTime endTime,
  }) : sessionId = Value(sessionId),
       kmIndex = Value(kmIndex),
       paceSecPerKm = Value(paceSecPerKm),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<SplitPace> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? kmIndex,
    Expression<int>? paceSecPerKm,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (kmIndex != null) 'km_index': kmIndex,
      if (paceSecPerKm != null) 'pace_sec_per_km': paceSecPerKm,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
    });
  }

  SplitPacesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? kmIndex,
    Value<int>? paceSecPerKm,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
  }) {
    return SplitPacesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      kmIndex: kmIndex ?? this.kmIndex,
      paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (kmIndex.present) {
      map['km_index'] = Variable<int>(kmIndex.value);
    }
    if (paceSecPerKm.present) {
      map['pace_sec_per_km'] = Variable<int>(paceSecPerKm.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitPacesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kmIndex: $kmIndex, ')
          ..write('paceSecPerKm: $paceSecPerKm, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    type,
    title,
    description,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final int sessionId;
  final String type;
  final String title;
  final String description;
  final DateTime achievedAt;
  const Achievement({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.title,
    required this.description,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      title: Value(title),
      description: Value(description),
      achievedAt: Value(achievedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
    };
  }

  Achievement copyWith({
    int? id,
    int? sessionId,
    String? type,
    String? title,
    String? description,
    DateTime? achievedAt,
  }) => Achievement(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, type, title, description, achievedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.achievedAt == this.achievedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> achievedAt;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.achievedAt = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String type,
    required String title,
    required String description,
    required DateTime achievedAt,
  }) : sessionId = Value(sessionId),
       type = Value(type),
       title = Value(title),
       description = Value(description),
       achievedAt = Value(achievedAt);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? achievedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (achievedAt != null) 'achieved_at': achievedAt,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? achievedAt,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }
}

class $TrainingPlansTable extends TrainingPlans
    with TableInfo<$TrainingPlansTable, TrainingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalWeeksMeta = const VerificationMeta(
    'totalWeeks',
  );
  @override
  late final GeneratedColumn<int> totalWeeks = GeneratedColumn<int>(
    'total_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    totalWeeks,
    isBuiltIn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('total_weeks')) {
      context.handle(
        _totalWeeksMeta,
        totalWeeks.isAcceptableOrUnknown(data['total_weeks']!, _totalWeeksMeta),
      );
    } else if (isInserting) {
      context.missing(_totalWeeksMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      totalWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_weeks'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
    );
  }

  @override
  $TrainingPlansTable createAlias(String alias) {
    return $TrainingPlansTable(attachedDatabase, alias);
  }
}

class TrainingPlan extends DataClass implements Insertable<TrainingPlan> {
  final int id;
  final String name;
  final String description;
  final int totalWeeks;
  final bool isBuiltIn;
  const TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.totalWeeks,
    required this.isBuiltIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['total_weeks'] = Variable<int>(totalWeeks);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    return map;
  }

  TrainingPlansCompanion toCompanion(bool nullToAbsent) {
    return TrainingPlansCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      totalWeeks: Value(totalWeeks),
      isBuiltIn: Value(isBuiltIn),
    );
  }

  factory TrainingPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingPlan(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      totalWeeks: serializer.fromJson<int>(json['totalWeeks']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'totalWeeks': serializer.toJson<int>(totalWeeks),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
    };
  }

  TrainingPlan copyWith({
    int? id,
    String? name,
    String? description,
    int? totalWeeks,
    bool? isBuiltIn,
  }) => TrainingPlan(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    totalWeeks: totalWeeks ?? this.totalWeeks,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
  TrainingPlan copyWithCompanion(TrainingPlansCompanion data) {
    return TrainingPlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      totalWeeks: data.totalWeeks.present
          ? data.totalWeeks.value
          : this.totalWeeks,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, totalWeeks, isBuiltIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingPlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.totalWeeks == this.totalWeeks &&
          other.isBuiltIn == this.isBuiltIn);
}

class TrainingPlansCompanion extends UpdateCompanion<TrainingPlan> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> totalWeeks;
  final Value<bool> isBuiltIn;
  const TrainingPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.totalWeeks = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  });
  TrainingPlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
    required int totalWeeks,
    this.isBuiltIn = const Value.absent(),
  }) : name = Value(name),
       description = Value(description),
       totalWeeks = Value(totalWeeks);
  static Insertable<TrainingPlan> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? totalWeeks,
    Expression<bool>? isBuiltIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (totalWeeks != null) 'total_weeks': totalWeeks,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
    });
  }

  TrainingPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? totalWeeks,
    Value<bool>? isBuiltIn,
  }) {
    return TrainingPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalWeeks.present) {
      map['total_weeks'] = Variable<int>(totalWeeks.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }
}

class $TrainingDaysTable extends TrainingDays
    with TableInfo<$TrainingDaysTable, TrainingDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_plans (id)',
    ),
  );
  static const VerificationMeta _weekIndexMeta = const VerificationMeta(
    'weekIndex',
  );
  @override
  late final GeneratedColumn<int> weekIndex = GeneratedColumn<int>(
    'week_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDistanceMetersMeta =
      const VerificationMeta('targetDistanceMeters');
  @override
  late final GeneratedColumn<int> targetDistanceMeters = GeneratedColumn<int>(
    'target_distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPaceSecPerKmMeta =
      const VerificationMeta('targetPaceSecPerKm');
  @override
  late final GeneratedColumn<int> targetPaceSecPerKm = GeneratedColumn<int>(
    'target_pace_sec_per_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalsMeta = const VerificationMeta(
    'intervals',
  );
  @override
  late final GeneratedColumn<String> intervals = GeneratedColumn<String>(
    'intervals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    weekIndex,
    dayIndex,
    type,
    targetDistanceMeters,
    targetPaceSecPerKm,
    intervals,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('week_index')) {
      context.handle(
        _weekIndexMeta,
        weekIndex.isAcceptableOrUnknown(data['week_index']!, _weekIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_weekIndexMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_distance_meters')) {
      context.handle(
        _targetDistanceMetersMeta,
        targetDistanceMeters.isAcceptableOrUnknown(
          data['target_distance_meters']!,
          _targetDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('target_pace_sec_per_km')) {
      context.handle(
        _targetPaceSecPerKmMeta,
        targetPaceSecPerKm.isAcceptableOrUnknown(
          data['target_pace_sec_per_km']!,
          _targetPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('intervals')) {
      context.handle(
        _intervalsMeta,
        intervals.isAcceptableOrUnknown(data['intervals']!, _intervalsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      weekIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_index'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_distance_meters'],
      ),
      targetPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_pace_sec_per_km'],
      ),
      intervals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervals'],
      ),
    );
  }

  @override
  $TrainingDaysTable createAlias(String alias) {
    return $TrainingDaysTable(attachedDatabase, alias);
  }
}

class TrainingDay extends DataClass implements Insertable<TrainingDay> {
  final int id;
  final int planId;
  final int weekIndex;
  final int dayIndex;
  final String type;
  final int? targetDistanceMeters;
  final int? targetPaceSecPerKm;
  final String? intervals;
  const TrainingDay({
    required this.id,
    required this.planId,
    required this.weekIndex,
    required this.dayIndex,
    required this.type,
    this.targetDistanceMeters,
    this.targetPaceSecPerKm,
    this.intervals,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['week_index'] = Variable<int>(weekIndex);
    map['day_index'] = Variable<int>(dayIndex);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || targetDistanceMeters != null) {
      map['target_distance_meters'] = Variable<int>(targetDistanceMeters);
    }
    if (!nullToAbsent || targetPaceSecPerKm != null) {
      map['target_pace_sec_per_km'] = Variable<int>(targetPaceSecPerKm);
    }
    if (!nullToAbsent || intervals != null) {
      map['intervals'] = Variable<String>(intervals);
    }
    return map;
  }

  TrainingDaysCompanion toCompanion(bool nullToAbsent) {
    return TrainingDaysCompanion(
      id: Value(id),
      planId: Value(planId),
      weekIndex: Value(weekIndex),
      dayIndex: Value(dayIndex),
      type: Value(type),
      targetDistanceMeters: targetDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDistanceMeters),
      targetPaceSecPerKm: targetPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPaceSecPerKm),
      intervals: intervals == null && nullToAbsent
          ? const Value.absent()
          : Value(intervals),
    );
  }

  factory TrainingDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingDay(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      weekIndex: serializer.fromJson<int>(json['weekIndex']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      type: serializer.fromJson<String>(json['type']),
      targetDistanceMeters: serializer.fromJson<int?>(
        json['targetDistanceMeters'],
      ),
      targetPaceSecPerKm: serializer.fromJson<int?>(json['targetPaceSecPerKm']),
      intervals: serializer.fromJson<String?>(json['intervals']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'weekIndex': serializer.toJson<int>(weekIndex),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'type': serializer.toJson<String>(type),
      'targetDistanceMeters': serializer.toJson<int?>(targetDistanceMeters),
      'targetPaceSecPerKm': serializer.toJson<int?>(targetPaceSecPerKm),
      'intervals': serializer.toJson<String?>(intervals),
    };
  }

  TrainingDay copyWith({
    int? id,
    int? planId,
    int? weekIndex,
    int? dayIndex,
    String? type,
    Value<int?> targetDistanceMeters = const Value.absent(),
    Value<int?> targetPaceSecPerKm = const Value.absent(),
    Value<String?> intervals = const Value.absent(),
  }) => TrainingDay(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    weekIndex: weekIndex ?? this.weekIndex,
    dayIndex: dayIndex ?? this.dayIndex,
    type: type ?? this.type,
    targetDistanceMeters: targetDistanceMeters.present
        ? targetDistanceMeters.value
        : this.targetDistanceMeters,
    targetPaceSecPerKm: targetPaceSecPerKm.present
        ? targetPaceSecPerKm.value
        : this.targetPaceSecPerKm,
    intervals: intervals.present ? intervals.value : this.intervals,
  );
  TrainingDay copyWithCompanion(TrainingDaysCompanion data) {
    return TrainingDay(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      weekIndex: data.weekIndex.present ? data.weekIndex.value : this.weekIndex,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      type: data.type.present ? data.type.value : this.type,
      targetDistanceMeters: data.targetDistanceMeters.present
          ? data.targetDistanceMeters.value
          : this.targetDistanceMeters,
      targetPaceSecPerKm: data.targetPaceSecPerKm.present
          ? data.targetPaceSecPerKm.value
          : this.targetPaceSecPerKm,
      intervals: data.intervals.present ? data.intervals.value : this.intervals,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingDay(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('weekIndex: $weekIndex, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('type: $type, ')
          ..write('targetDistanceMeters: $targetDistanceMeters, ')
          ..write('targetPaceSecPerKm: $targetPaceSecPerKm, ')
          ..write('intervals: $intervals')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    weekIndex,
    dayIndex,
    type,
    targetDistanceMeters,
    targetPaceSecPerKm,
    intervals,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingDay &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.weekIndex == this.weekIndex &&
          other.dayIndex == this.dayIndex &&
          other.type == this.type &&
          other.targetDistanceMeters == this.targetDistanceMeters &&
          other.targetPaceSecPerKm == this.targetPaceSecPerKm &&
          other.intervals == this.intervals);
}

class TrainingDaysCompanion extends UpdateCompanion<TrainingDay> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> weekIndex;
  final Value<int> dayIndex;
  final Value<String> type;
  final Value<int?> targetDistanceMeters;
  final Value<int?> targetPaceSecPerKm;
  final Value<String?> intervals;
  const TrainingDaysCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.weekIndex = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.type = const Value.absent(),
    this.targetDistanceMeters = const Value.absent(),
    this.targetPaceSecPerKm = const Value.absent(),
    this.intervals = const Value.absent(),
  });
  TrainingDaysCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int weekIndex,
    required int dayIndex,
    required String type,
    this.targetDistanceMeters = const Value.absent(),
    this.targetPaceSecPerKm = const Value.absent(),
    this.intervals = const Value.absent(),
  }) : planId = Value(planId),
       weekIndex = Value(weekIndex),
       dayIndex = Value(dayIndex),
       type = Value(type);
  static Insertable<TrainingDay> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? weekIndex,
    Expression<int>? dayIndex,
    Expression<String>? type,
    Expression<int>? targetDistanceMeters,
    Expression<int>? targetPaceSecPerKm,
    Expression<String>? intervals,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (weekIndex != null) 'week_index': weekIndex,
      if (dayIndex != null) 'day_index': dayIndex,
      if (type != null) 'type': type,
      if (targetDistanceMeters != null)
        'target_distance_meters': targetDistanceMeters,
      if (targetPaceSecPerKm != null)
        'target_pace_sec_per_km': targetPaceSecPerKm,
      if (intervals != null) 'intervals': intervals,
    });
  }

  TrainingDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int>? weekIndex,
    Value<int>? dayIndex,
    Value<String>? type,
    Value<int?>? targetDistanceMeters,
    Value<int?>? targetPaceSecPerKm,
    Value<String?>? intervals,
  }) {
    return TrainingDaysCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      weekIndex: weekIndex ?? this.weekIndex,
      dayIndex: dayIndex ?? this.dayIndex,
      type: type ?? this.type,
      targetDistanceMeters: targetDistanceMeters ?? this.targetDistanceMeters,
      targetPaceSecPerKm: targetPaceSecPerKm ?? this.targetPaceSecPerKm,
      intervals: intervals ?? this.intervals,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (weekIndex.present) {
      map['week_index'] = Variable<int>(weekIndex.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetDistanceMeters.present) {
      map['target_distance_meters'] = Variable<int>(targetDistanceMeters.value);
    }
    if (targetPaceSecPerKm.present) {
      map['target_pace_sec_per_km'] = Variable<int>(targetPaceSecPerKm.value);
    }
    if (intervals.present) {
      map['intervals'] = Variable<String>(intervals.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingDaysCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('weekIndex: $weekIndex, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('type: $type, ')
          ..write('targetDistanceMeters: $targetDistanceMeters, ')
          ..write('targetPaceSecPerKm: $targetPaceSecPerKm, ')
          ..write('intervals: $intervals')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryTypeMeta = const VerificationMeta(
    'summaryType',
  );
  @override
  late final GeneratedColumn<String> summaryType = GeneratedColumn<String>(
    'summary_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    sessionId,
    summaryType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('summary_type')) {
      context.handle(
        _summaryTypeMeta,
        summaryType.isAcceptableOrUnknown(
          data['summary_type']!,
          _summaryTypeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      summaryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String conversationId;
  final String role;
  final String content;
  final int? sessionId;
  final String? summaryType;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.sessionId,
    this.summaryType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || summaryType != null) {
      map['summary_type'] = Variable<String>(summaryType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      summaryType: summaryType == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryType),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      summaryType: serializer.fromJson<String?>(json['summaryType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'sessionId': serializer.toJson<int?>(sessionId),
      'summaryType': serializer.toJson<String?>(summaryType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? conversationId,
    String? role,
    String? content,
    Value<int?> sessionId = const Value.absent(),
    Value<String?> summaryType = const Value.absent(),
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    summaryType: summaryType.present ? summaryType.value : this.summaryType,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      summaryType: data.summaryType.present
          ? data.summaryType.value
          : this.summaryType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('sessionId: $sessionId, ')
          ..write('summaryType: $summaryType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    sessionId,
    summaryType,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.sessionId == this.sessionId &&
          other.summaryType == this.summaryType &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<int?> sessionId;
  final Value<String?> summaryType;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.summaryType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String conversationId,
    required String role,
    required String content,
    this.sessionId = const Value.absent(),
    this.summaryType = const Value.absent(),
    required DateTime createdAt,
  }) : conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<int>? sessionId,
    Expression<String>? summaryType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (sessionId != null) 'session_id': sessionId,
      if (summaryType != null) 'summary_type': summaryType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<int?>? sessionId,
    Value<String?>? summaryType,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      sessionId: sessionId ?? this.sessionId,
      summaryType: summaryType ?? this.summaryType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (summaryType.present) {
      map['summary_type'] = Variable<String>(summaryType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('sessionId: $sessionId, ')
          ..write('summaryType: $summaryType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudienceShoutsTable extends AudienceShouts
    with TableInfo<$AudienceShoutsTable, AudienceShout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudienceShoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id)',
    ),
  );
  static const VerificationMeta _audienceRoleMeta = const VerificationMeta(
    'audienceRole',
  );
  @override
  late final GeneratedColumn<String> audienceRole = GeneratedColumn<String>(
    'audience_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personalityMeta = const VerificationMeta(
    'personality',
  );
  @override
  late final GeneratedColumn<String> personality = GeneratedColumn<String>(
    'personality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerTypeMeta = const VerificationMeta(
    'triggerType',
  );
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
    'trigger_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerKmMeta = const VerificationMeta(
    'triggerKm',
  );
  @override
  late final GeneratedColumn<int> triggerKm = GeneratedColumn<int>(
    'trigger_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _triggerContextMeta = const VerificationMeta(
    'triggerContext',
  );
  @override
  late final GeneratedColumn<String> triggerContext = GeneratedColumn<String>(
    'trigger_context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    audienceRole,
    personality,
    triggerType,
    triggerKm,
    content,
    isFavorite,
    triggerContext,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audience_shouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudienceShout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('audience_role')) {
      context.handle(
        _audienceRoleMeta,
        audienceRole.isAcceptableOrUnknown(
          data['audience_role']!,
          _audienceRoleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audienceRoleMeta);
    }
    if (data.containsKey('personality')) {
      context.handle(
        _personalityMeta,
        personality.isAcceptableOrUnknown(
          data['personality']!,
          _personalityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personalityMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
        _triggerTypeMeta,
        triggerType.isAcceptableOrUnknown(
          data['trigger_type']!,
          _triggerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('trigger_km')) {
      context.handle(
        _triggerKmMeta,
        triggerKm.isAcceptableOrUnknown(data['trigger_km']!, _triggerKmMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('trigger_context')) {
      context.handle(
        _triggerContextMeta,
        triggerContext.isAcceptableOrUnknown(
          data['trigger_context']!,
          _triggerContextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerContextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudienceShout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudienceShout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      audienceRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience_role'],
      )!,
      personality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personality'],
      )!,
      triggerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_type'],
      )!,
      triggerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trigger_km'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      triggerContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_context'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AudienceShoutsTable createAlias(String alias) {
    return $AudienceShoutsTable(attachedDatabase, alias);
  }
}

class AudienceShout extends DataClass implements Insertable<AudienceShout> {
  final int id;
  final int sessionId;
  final String audienceRole;
  final String personality;
  final String triggerType;
  final int? triggerKm;
  final String content;
  final bool isFavorite;
  final String triggerContext;
  final DateTime createdAt;
  const AudienceShout({
    required this.id,
    required this.sessionId,
    required this.audienceRole,
    required this.personality,
    required this.triggerType,
    this.triggerKm,
    required this.content,
    required this.isFavorite,
    required this.triggerContext,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['audience_role'] = Variable<String>(audienceRole);
    map['personality'] = Variable<String>(personality);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || triggerKm != null) {
      map['trigger_km'] = Variable<int>(triggerKm);
    }
    map['content'] = Variable<String>(content);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['trigger_context'] = Variable<String>(triggerContext);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AudienceShoutsCompanion toCompanion(bool nullToAbsent) {
    return AudienceShoutsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      audienceRole: Value(audienceRole),
      personality: Value(personality),
      triggerType: Value(triggerType),
      triggerKm: triggerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerKm),
      content: Value(content),
      isFavorite: Value(isFavorite),
      triggerContext: Value(triggerContext),
      createdAt: Value(createdAt),
    );
  }

  factory AudienceShout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudienceShout(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      audienceRole: serializer.fromJson<String>(json['audienceRole']),
      personality: serializer.fromJson<String>(json['personality']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      triggerKm: serializer.fromJson<int?>(json['triggerKm']),
      content: serializer.fromJson<String>(json['content']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      triggerContext: serializer.fromJson<String>(json['triggerContext']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'audienceRole': serializer.toJson<String>(audienceRole),
      'personality': serializer.toJson<String>(personality),
      'triggerType': serializer.toJson<String>(triggerType),
      'triggerKm': serializer.toJson<int?>(triggerKm),
      'content': serializer.toJson<String>(content),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'triggerContext': serializer.toJson<String>(triggerContext),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AudienceShout copyWith({
    int? id,
    int? sessionId,
    String? audienceRole,
    String? personality,
    String? triggerType,
    Value<int?> triggerKm = const Value.absent(),
    String? content,
    bool? isFavorite,
    String? triggerContext,
    DateTime? createdAt,
  }) => AudienceShout(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    audienceRole: audienceRole ?? this.audienceRole,
    personality: personality ?? this.personality,
    triggerType: triggerType ?? this.triggerType,
    triggerKm: triggerKm.present ? triggerKm.value : this.triggerKm,
    content: content ?? this.content,
    isFavorite: isFavorite ?? this.isFavorite,
    triggerContext: triggerContext ?? this.triggerContext,
    createdAt: createdAt ?? this.createdAt,
  );
  AudienceShout copyWithCompanion(AudienceShoutsCompanion data) {
    return AudienceShout(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      audienceRole: data.audienceRole.present
          ? data.audienceRole.value
          : this.audienceRole,
      personality: data.personality.present
          ? data.personality.value
          : this.personality,
      triggerType: data.triggerType.present
          ? data.triggerType.value
          : this.triggerType,
      triggerKm: data.triggerKm.present ? data.triggerKm.value : this.triggerKm,
      content: data.content.present ? data.content.value : this.content,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      triggerContext: data.triggerContext.present
          ? data.triggerContext.value
          : this.triggerContext,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudienceShout(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('personality: $personality, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerKm: $triggerKm, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('triggerContext: $triggerContext, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    audienceRole,
    personality,
    triggerType,
    triggerKm,
    content,
    isFavorite,
    triggerContext,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudienceShout &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.audienceRole == this.audienceRole &&
          other.personality == this.personality &&
          other.triggerType == this.triggerType &&
          other.triggerKm == this.triggerKm &&
          other.content == this.content &&
          other.isFavorite == this.isFavorite &&
          other.triggerContext == this.triggerContext &&
          other.createdAt == this.createdAt);
}

class AudienceShoutsCompanion extends UpdateCompanion<AudienceShout> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> audienceRole;
  final Value<String> personality;
  final Value<String> triggerType;
  final Value<int?> triggerKm;
  final Value<String> content;
  final Value<bool> isFavorite;
  final Value<String> triggerContext;
  final Value<DateTime> createdAt;
  const AudienceShoutsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.audienceRole = const Value.absent(),
    this.personality = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerKm = const Value.absent(),
    this.content = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.triggerContext = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AudienceShoutsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String audienceRole,
    required String personality,
    required String triggerType,
    this.triggerKm = const Value.absent(),
    required String content,
    this.isFavorite = const Value.absent(),
    required String triggerContext,
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       audienceRole = Value(audienceRole),
       personality = Value(personality),
       triggerType = Value(triggerType),
       content = Value(content),
       triggerContext = Value(triggerContext),
       createdAt = Value(createdAt);
  static Insertable<AudienceShout> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? audienceRole,
    Expression<String>? personality,
    Expression<String>? triggerType,
    Expression<int>? triggerKm,
    Expression<String>? content,
    Expression<bool>? isFavorite,
    Expression<String>? triggerContext,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (audienceRole != null) 'audience_role': audienceRole,
      if (personality != null) 'personality': personality,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerKm != null) 'trigger_km': triggerKm,
      if (content != null) 'content': content,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (triggerContext != null) 'trigger_context': triggerContext,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AudienceShoutsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? audienceRole,
    Value<String>? personality,
    Value<String>? triggerType,
    Value<int?>? triggerKm,
    Value<String>? content,
    Value<bool>? isFavorite,
    Value<String>? triggerContext,
    Value<DateTime>? createdAt,
  }) {
    return AudienceShoutsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      audienceRole: audienceRole ?? this.audienceRole,
      personality: personality ?? this.personality,
      triggerType: triggerType ?? this.triggerType,
      triggerKm: triggerKm ?? this.triggerKm,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      triggerContext: triggerContext ?? this.triggerContext,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (audienceRole.present) {
      map['audience_role'] = Variable<String>(audienceRole.value);
    }
    if (personality.present) {
      map['personality'] = Variable<String>(personality.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (triggerKm.present) {
      map['trigger_km'] = Variable<int>(triggerKm.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (triggerContext.present) {
      map['trigger_context'] = Variable<String>(triggerContext.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudienceShoutsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('personality: $personality, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerKm: $triggerKm, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('triggerContext: $triggerContext, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudienceFavoritesTable extends AudienceFavorites
    with TableInfo<$AudienceFavoritesTable, AudienceFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudienceFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _audienceRoleMeta = const VerificationMeta(
    'audienceRole',
  );
  @override
  late final GeneratedColumn<String> audienceRole = GeneratedColumn<String>(
    'audience_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personalityMeta = const VerificationMeta(
    'personality',
  );
  @override
  late final GeneratedColumn<String> personality = GeneratedColumn<String>(
    'personality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _representativeShoutIdMeta =
      const VerificationMeta('representativeShoutId');
  @override
  late final GeneratedColumn<int> representativeShoutId = GeneratedColumn<int>(
    'representative_shout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audience_shouts (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    audienceRole,
    personality,
    representativeShoutId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audience_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudienceFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audience_role')) {
      context.handle(
        _audienceRoleMeta,
        audienceRole.isAcceptableOrUnknown(
          data['audience_role']!,
          _audienceRoleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audienceRoleMeta);
    }
    if (data.containsKey('personality')) {
      context.handle(
        _personalityMeta,
        personality.isAcceptableOrUnknown(
          data['personality']!,
          _personalityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personalityMeta);
    }
    if (data.containsKey('representative_shout_id')) {
      context.handle(
        _representativeShoutIdMeta,
        representativeShoutId.isAcceptableOrUnknown(
          data['representative_shout_id']!,
          _representativeShoutIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudienceFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudienceFavorite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      audienceRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience_role'],
      )!,
      personality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personality'],
      )!,
      representativeShoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}representative_shout_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AudienceFavoritesTable createAlias(String alias) {
    return $AudienceFavoritesTable(attachedDatabase, alias);
  }
}

class AudienceFavorite extends DataClass
    implements Insertable<AudienceFavorite> {
  final int id;
  final String audienceRole;
  final String personality;
  final int? representativeShoutId;
  final DateTime createdAt;
  const AudienceFavorite({
    required this.id,
    required this.audienceRole,
    required this.personality,
    this.representativeShoutId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audience_role'] = Variable<String>(audienceRole);
    map['personality'] = Variable<String>(personality);
    if (!nullToAbsent || representativeShoutId != null) {
      map['representative_shout_id'] = Variable<int>(representativeShoutId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AudienceFavoritesCompanion toCompanion(bool nullToAbsent) {
    return AudienceFavoritesCompanion(
      id: Value(id),
      audienceRole: Value(audienceRole),
      personality: Value(personality),
      representativeShoutId: representativeShoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(representativeShoutId),
      createdAt: Value(createdAt),
    );
  }

  factory AudienceFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudienceFavorite(
      id: serializer.fromJson<int>(json['id']),
      audienceRole: serializer.fromJson<String>(json['audienceRole']),
      personality: serializer.fromJson<String>(json['personality']),
      representativeShoutId: serializer.fromJson<int?>(
        json['representativeShoutId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audienceRole': serializer.toJson<String>(audienceRole),
      'personality': serializer.toJson<String>(personality),
      'representativeShoutId': serializer.toJson<int?>(representativeShoutId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AudienceFavorite copyWith({
    int? id,
    String? audienceRole,
    String? personality,
    Value<int?> representativeShoutId = const Value.absent(),
    DateTime? createdAt,
  }) => AudienceFavorite(
    id: id ?? this.id,
    audienceRole: audienceRole ?? this.audienceRole,
    personality: personality ?? this.personality,
    representativeShoutId: representativeShoutId.present
        ? representativeShoutId.value
        : this.representativeShoutId,
    createdAt: createdAt ?? this.createdAt,
  );
  AudienceFavorite copyWithCompanion(AudienceFavoritesCompanion data) {
    return AudienceFavorite(
      id: data.id.present ? data.id.value : this.id,
      audienceRole: data.audienceRole.present
          ? data.audienceRole.value
          : this.audienceRole,
      personality: data.personality.present
          ? data.personality.value
          : this.personality,
      representativeShoutId: data.representativeShoutId.present
          ? data.representativeShoutId.value
          : this.representativeShoutId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudienceFavorite(')
          ..write('id: $id, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('personality: $personality, ')
          ..write('representativeShoutId: $representativeShoutId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    audienceRole,
    personality,
    representativeShoutId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudienceFavorite &&
          other.id == this.id &&
          other.audienceRole == this.audienceRole &&
          other.personality == this.personality &&
          other.representativeShoutId == this.representativeShoutId &&
          other.createdAt == this.createdAt);
}

class AudienceFavoritesCompanion extends UpdateCompanion<AudienceFavorite> {
  final Value<int> id;
  final Value<String> audienceRole;
  final Value<String> personality;
  final Value<int?> representativeShoutId;
  final Value<DateTime> createdAt;
  const AudienceFavoritesCompanion({
    this.id = const Value.absent(),
    this.audienceRole = const Value.absent(),
    this.personality = const Value.absent(),
    this.representativeShoutId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AudienceFavoritesCompanion.insert({
    this.id = const Value.absent(),
    required String audienceRole,
    required String personality,
    this.representativeShoutId = const Value.absent(),
    required DateTime createdAt,
  }) : audienceRole = Value(audienceRole),
       personality = Value(personality),
       createdAt = Value(createdAt);
  static Insertable<AudienceFavorite> custom({
    Expression<int>? id,
    Expression<String>? audienceRole,
    Expression<String>? personality,
    Expression<int>? representativeShoutId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audienceRole != null) 'audience_role': audienceRole,
      if (personality != null) 'personality': personality,
      if (representativeShoutId != null)
        'representative_shout_id': representativeShoutId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AudienceFavoritesCompanion copyWith({
    Value<int>? id,
    Value<String>? audienceRole,
    Value<String>? personality,
    Value<int?>? representativeShoutId,
    Value<DateTime>? createdAt,
  }) {
    return AudienceFavoritesCompanion(
      id: id ?? this.id,
      audienceRole: audienceRole ?? this.audienceRole,
      personality: personality ?? this.personality,
      representativeShoutId:
          representativeShoutId ?? this.representativeShoutId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audienceRole.present) {
      map['audience_role'] = Variable<String>(audienceRole.value);
    }
    if (personality.present) {
      map['personality'] = Variable<String>(personality.value);
    }
    if (representativeShoutId.present) {
      map['representative_shout_id'] = Variable<int>(
        representativeShoutId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudienceFavoritesCompanion(')
          ..write('id: $id, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('personality: $personality, ')
          ..write('representativeShoutId: $representativeShoutId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudienceUnlocksTable extends AudienceUnlocks
    with TableInfo<$AudienceUnlocksTable, AudienceUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudienceUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _audienceRoleMeta = const VerificationMeta(
    'audienceRole',
  );
  @override
  late final GeneratedColumn<String> audienceRole = GeneratedColumn<String>(
    'audience_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtRunCountMeta =
      const VerificationMeta('unlockedAtRunCount');
  @override
  late final GeneratedColumn<int> unlockedAtRunCount = GeneratedColumn<int>(
    'unlocked_at_run_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasSeenAnimationMeta = const VerificationMeta(
    'hasSeenAnimation',
  );
  @override
  late final GeneratedColumn<bool> hasSeenAnimation = GeneratedColumn<bool>(
    'has_seen_animation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_seen_animation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    audienceRole,
    unlockedAt,
    unlockedAtRunCount,
    hasSeenAnimation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audience_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudienceUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audience_role')) {
      context.handle(
        _audienceRoleMeta,
        audienceRole.isAcceptableOrUnknown(
          data['audience_role']!,
          _audienceRoleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audienceRoleMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    if (data.containsKey('unlocked_at_run_count')) {
      context.handle(
        _unlockedAtRunCountMeta,
        unlockedAtRunCount.isAcceptableOrUnknown(
          data['unlocked_at_run_count']!,
          _unlockedAtRunCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtRunCountMeta);
    }
    if (data.containsKey('has_seen_animation')) {
      context.handle(
        _hasSeenAnimationMeta,
        hasSeenAnimation.isAcceptableOrUnknown(
          data['has_seen_animation']!,
          _hasSeenAnimationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudienceUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudienceUnlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      audienceRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience_role'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
      unlockedAtRunCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at_run_count'],
      )!,
      hasSeenAnimation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_seen_animation'],
      )!,
    );
  }

  @override
  $AudienceUnlocksTable createAlias(String alias) {
    return $AudienceUnlocksTable(attachedDatabase, alias);
  }
}

class AudienceUnlock extends DataClass implements Insertable<AudienceUnlock> {
  final int id;
  final String audienceRole;
  final DateTime unlockedAt;
  final int unlockedAtRunCount;
  final bool hasSeenAnimation;
  const AudienceUnlock({
    required this.id,
    required this.audienceRole,
    required this.unlockedAt,
    required this.unlockedAtRunCount,
    required this.hasSeenAnimation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audience_role'] = Variable<String>(audienceRole);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    map['unlocked_at_run_count'] = Variable<int>(unlockedAtRunCount);
    map['has_seen_animation'] = Variable<bool>(hasSeenAnimation);
    return map;
  }

  AudienceUnlocksCompanion toCompanion(bool nullToAbsent) {
    return AudienceUnlocksCompanion(
      id: Value(id),
      audienceRole: Value(audienceRole),
      unlockedAt: Value(unlockedAt),
      unlockedAtRunCount: Value(unlockedAtRunCount),
      hasSeenAnimation: Value(hasSeenAnimation),
    );
  }

  factory AudienceUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudienceUnlock(
      id: serializer.fromJson<int>(json['id']),
      audienceRole: serializer.fromJson<String>(json['audienceRole']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
      unlockedAtRunCount: serializer.fromJson<int>(json['unlockedAtRunCount']),
      hasSeenAnimation: serializer.fromJson<bool>(json['hasSeenAnimation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audienceRole': serializer.toJson<String>(audienceRole),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
      'unlockedAtRunCount': serializer.toJson<int>(unlockedAtRunCount),
      'hasSeenAnimation': serializer.toJson<bool>(hasSeenAnimation),
    };
  }

  AudienceUnlock copyWith({
    int? id,
    String? audienceRole,
    DateTime? unlockedAt,
    int? unlockedAtRunCount,
    bool? hasSeenAnimation,
  }) => AudienceUnlock(
    id: id ?? this.id,
    audienceRole: audienceRole ?? this.audienceRole,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    unlockedAtRunCount: unlockedAtRunCount ?? this.unlockedAtRunCount,
    hasSeenAnimation: hasSeenAnimation ?? this.hasSeenAnimation,
  );
  AudienceUnlock copyWithCompanion(AudienceUnlocksCompanion data) {
    return AudienceUnlock(
      id: data.id.present ? data.id.value : this.id,
      audienceRole: data.audienceRole.present
          ? data.audienceRole.value
          : this.audienceRole,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      unlockedAtRunCount: data.unlockedAtRunCount.present
          ? data.unlockedAtRunCount.value
          : this.unlockedAtRunCount,
      hasSeenAnimation: data.hasSeenAnimation.present
          ? data.hasSeenAnimation.value
          : this.hasSeenAnimation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudienceUnlock(')
          ..write('id: $id, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('unlockedAtRunCount: $unlockedAtRunCount, ')
          ..write('hasSeenAnimation: $hasSeenAnimation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    audienceRole,
    unlockedAt,
    unlockedAtRunCount,
    hasSeenAnimation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudienceUnlock &&
          other.id == this.id &&
          other.audienceRole == this.audienceRole &&
          other.unlockedAt == this.unlockedAt &&
          other.unlockedAtRunCount == this.unlockedAtRunCount &&
          other.hasSeenAnimation == this.hasSeenAnimation);
}

class AudienceUnlocksCompanion extends UpdateCompanion<AudienceUnlock> {
  final Value<int> id;
  final Value<String> audienceRole;
  final Value<DateTime> unlockedAt;
  final Value<int> unlockedAtRunCount;
  final Value<bool> hasSeenAnimation;
  const AudienceUnlocksCompanion({
    this.id = const Value.absent(),
    this.audienceRole = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.unlockedAtRunCount = const Value.absent(),
    this.hasSeenAnimation = const Value.absent(),
  });
  AudienceUnlocksCompanion.insert({
    this.id = const Value.absent(),
    required String audienceRole,
    required DateTime unlockedAt,
    required int unlockedAtRunCount,
    this.hasSeenAnimation = const Value.absent(),
  }) : audienceRole = Value(audienceRole),
       unlockedAt = Value(unlockedAt),
       unlockedAtRunCount = Value(unlockedAtRunCount);
  static Insertable<AudienceUnlock> custom({
    Expression<int>? id,
    Expression<String>? audienceRole,
    Expression<DateTime>? unlockedAt,
    Expression<int>? unlockedAtRunCount,
    Expression<bool>? hasSeenAnimation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audienceRole != null) 'audience_role': audienceRole,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (unlockedAtRunCount != null)
        'unlocked_at_run_count': unlockedAtRunCount,
      if (hasSeenAnimation != null) 'has_seen_animation': hasSeenAnimation,
    });
  }

  AudienceUnlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? audienceRole,
    Value<DateTime>? unlockedAt,
    Value<int>? unlockedAtRunCount,
    Value<bool>? hasSeenAnimation,
  }) {
    return AudienceUnlocksCompanion(
      id: id ?? this.id,
      audienceRole: audienceRole ?? this.audienceRole,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedAtRunCount: unlockedAtRunCount ?? this.unlockedAtRunCount,
      hasSeenAnimation: hasSeenAnimation ?? this.hasSeenAnimation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audienceRole.present) {
      map['audience_role'] = Variable<String>(audienceRole.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (unlockedAtRunCount.present) {
      map['unlocked_at_run_count'] = Variable<int>(unlockedAtRunCount.value);
    }
    if (hasSeenAnimation.present) {
      map['has_seen_animation'] = Variable<bool>(hasSeenAnimation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudienceUnlocksCompanion(')
          ..write('id: $id, ')
          ..write('audienceRole: $audienceRole, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('unlockedAtRunCount: $unlockedAtRunCount, ')
          ..write('hasSeenAnimation: $hasSeenAnimation')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunSessionsTable runSessions = $RunSessionsTable(this);
  late final $RoutePointsTable routePoints = $RoutePointsTable(this);
  late final $SplitPacesTable splitPaces = $SplitPacesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $TrainingPlansTable trainingPlans = $TrainingPlansTable(this);
  late final $TrainingDaysTable trainingDays = $TrainingDaysTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $AudienceShoutsTable audienceShouts = $AudienceShoutsTable(this);
  late final $AudienceFavoritesTable audienceFavorites =
      $AudienceFavoritesTable(this);
  late final $AudienceUnlocksTable audienceUnlocks = $AudienceUnlocksTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runSessions,
    routePoints,
    splitPaces,
    achievements,
    trainingPlans,
    trainingDays,
    chatMessages,
    audienceShouts,
    audienceFavorites,
    audienceUnlocks,
  ];
}

typedef $$RunSessionsTableCreateCompanionBuilder =
    RunSessionsCompanion Function({
      Value<int> id,
      Value<String> status,
      required DateTime startTime,
      Value<DateTime?> endTime,
      required int durationSeconds,
      required double distanceMeters,
      required int avgPaceSecPerKm,
      required int bestPaceSecPerKm,
      Value<int> caloriesKcal,
      Value<double> elevationGainMeters,
      Value<String> autoName,
      Value<String?> city,
      Value<String?> weather,
    });
typedef $$RunSessionsTableUpdateCompanionBuilder =
    RunSessionsCompanion Function({
      Value<int> id,
      Value<String> status,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> durationSeconds,
      Value<double> distanceMeters,
      Value<int> avgPaceSecPerKm,
      Value<int> bestPaceSecPerKm,
      Value<int> caloriesKcal,
      Value<double> elevationGainMeters,
      Value<String> autoName,
      Value<String?> city,
      Value<String?> weather,
    });

final class $$RunSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $RunSessionsTable, RunSession> {
  $$RunSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutePointsTable, List<RoutePoint>>
  _routePointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routePoints,
    aliasName: $_aliasNameGenerator(
      db.runSessions.id,
      db.routePoints.sessionId,
    ),
  );

  $$RoutePointsTableProcessedTableManager get routePointsRefs {
    final manager = $$RoutePointsTableTableManager(
      $_db,
      $_db.routePoints,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routePointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitPacesTable, List<SplitPace>>
  _splitPacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitPaces,
    aliasName: $_aliasNameGenerator(db.runSessions.id, db.splitPaces.sessionId),
  );

  $$SplitPacesTableProcessedTableManager get splitPacesRefs {
    final manager = $$SplitPacesTableTableManager(
      $_db,
      $_db.splitPaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitPacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AchievementsTable, List<Achievement>>
  _achievementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.achievements,
    aliasName: $_aliasNameGenerator(
      db.runSessions.id,
      db.achievements.sessionId,
    ),
  );

  $$AchievementsTableProcessedTableManager get achievementsRefs {
    final manager = $$AchievementsTableTableManager(
      $_db,
      $_db.achievements,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_achievementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudienceShoutsTable, List<AudienceShout>>
  _audienceShoutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audienceShouts,
    aliasName: $_aliasNameGenerator(
      db.runSessions.id,
      db.audienceShouts.sessionId,
    ),
  );

  $$AudienceShoutsTableProcessedTableManager get audienceShoutsRefs {
    final manager = $$AudienceShoutsTableTableManager(
      $_db,
      $_db.audienceShouts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audienceShoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestPaceSecPerKm => $composableBuilder(
    column: $table.bestPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routePointsRefs(
    Expression<bool> Function($$RoutePointsTableFilterComposer f) f,
  ) {
    final $$RoutePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableFilterComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitPacesRefs(
    Expression<bool> Function($$SplitPacesTableFilterComposer f) f,
  ) {
    final $$SplitPacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitPaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPacesTableFilterComposer(
            $db: $db,
            $table: $db.splitPaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> achievementsRefs(
    Expression<bool> Function($$AchievementsTableFilterComposer f) f,
  ) {
    final $$AchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableFilterComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audienceShoutsRefs(
    Expression<bool> Function($$AudienceShoutsTableFilterComposer f) f,
  ) {
    final $$AudienceShoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audienceShouts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceShoutsTableFilterComposer(
            $db: $db,
            $table: $db.audienceShouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestPaceSecPerKm => $composableBuilder(
    column: $table.bestPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgPaceSecPerKm => $composableBuilder(
    column: $table.avgPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestPaceSecPerKm => $composableBuilder(
    column: $table.bestPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoName =>
      $composableBuilder(column: $table.autoName, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  Expression<T> routePointsRefs<T extends Object>(
    Expression<T> Function($$RoutePointsTableAnnotationComposer a) f,
  ) {
    final $$RoutePointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableAnnotationComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitPacesRefs<T extends Object>(
    Expression<T> Function($$SplitPacesTableAnnotationComposer a) f,
  ) {
    final $$SplitPacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitPaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPacesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitPaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> achievementsRefs<T extends Object>(
    Expression<T> Function($$AchievementsTableAnnotationComposer a) f,
  ) {
    final $$AchievementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableAnnotationComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audienceShoutsRefs<T extends Object>(
    Expression<T> Function($$AudienceShoutsTableAnnotationComposer a) f,
  ) {
    final $$AudienceShoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audienceShouts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceShoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.audienceShouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunSessionsTable,
          RunSession,
          $$RunSessionsTableFilterComposer,
          $$RunSessionsTableOrderingComposer,
          $$RunSessionsTableAnnotationComposer,
          $$RunSessionsTableCreateCompanionBuilder,
          $$RunSessionsTableUpdateCompanionBuilder,
          (RunSession, $$RunSessionsTableReferences),
          RunSession,
          PrefetchHooks Function({
            bool routePointsRefs,
            bool splitPacesRefs,
            bool achievementsRefs,
            bool audienceShoutsRefs,
          })
        > {
  $$RunSessionsTableTableManager(_$AppDatabase db, $RunSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> avgPaceSecPerKm = const Value.absent(),
                Value<int> bestPaceSecPerKm = const Value.absent(),
                Value<int> caloriesKcal = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<String> autoName = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> weather = const Value.absent(),
              }) => RunSessionsCompanion(
                id: id,
                status: status,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                avgPaceSecPerKm: avgPaceSecPerKm,
                bestPaceSecPerKm: bestPaceSecPerKm,
                caloriesKcal: caloriesKcal,
                elevationGainMeters: elevationGainMeters,
                autoName: autoName,
                city: city,
                weather: weather,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                required int durationSeconds,
                required double distanceMeters,
                required int avgPaceSecPerKm,
                required int bestPaceSecPerKm,
                Value<int> caloriesKcal = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<String> autoName = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> weather = const Value.absent(),
              }) => RunSessionsCompanion.insert(
                id: id,
                status: status,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                avgPaceSecPerKm: avgPaceSecPerKm,
                bestPaceSecPerKm: bestPaceSecPerKm,
                caloriesKcal: caloriesKcal,
                elevationGainMeters: elevationGainMeters,
                autoName: autoName,
                city: city,
                weather: weather,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routePointsRefs = false,
                splitPacesRefs = false,
                achievementsRefs = false,
                audienceShoutsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routePointsRefs) db.routePoints,
                    if (splitPacesRefs) db.splitPaces,
                    if (achievementsRefs) db.achievements,
                    if (audienceShoutsRefs) db.audienceShouts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routePointsRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          RoutePoint
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._routePointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).routePointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (splitPacesRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          SplitPace
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._splitPacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).splitPacesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (achievementsRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          Achievement
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._achievementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).achievementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audienceShoutsRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          AudienceShout
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._audienceShoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).audienceShoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RunSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunSessionsTable,
      RunSession,
      $$RunSessionsTableFilterComposer,
      $$RunSessionsTableOrderingComposer,
      $$RunSessionsTableAnnotationComposer,
      $$RunSessionsTableCreateCompanionBuilder,
      $$RunSessionsTableUpdateCompanionBuilder,
      (RunSession, $$RunSessionsTableReferences),
      RunSession,
      PrefetchHooks Function({
        bool routePointsRefs,
        bool splitPacesRefs,
        bool achievementsRefs,
        bool audienceShoutsRefs,
      })
    >;
typedef $$RoutePointsTableCreateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      required int sessionId,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      required double accuracy,
      required double speed,
      required DateTime timestamp,
      required int orderIndex,
    });
typedef $$RoutePointsTableUpdateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double> accuracy,
      Value<double> speed,
      Value<DateTime> timestamp,
      Value<int> orderIndex,
    });

final class $$RoutePointsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutePointsTable, RoutePoint> {
  $$RoutePointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.routePoints.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutePointsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutePointsTable,
          RoutePoint,
          $$RoutePointsTableFilterComposer,
          $$RoutePointsTableOrderingComposer,
          $$RoutePointsTableAnnotationComposer,
          $$RoutePointsTableCreateCompanionBuilder,
          $$RoutePointsTableUpdateCompanionBuilder,
          (RoutePoint, $$RoutePointsTableReferences),
          RoutePoint,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RoutePointsTableTableManager(_$AppDatabase db, $RoutePointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutePointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => RoutePointsCompanion(
                id: id,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                speed: speed,
                timestamp: timestamp,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                required double accuracy,
                required double speed,
                required DateTime timestamp,
                required int orderIndex,
              }) => RoutePointsCompanion.insert(
                id: id,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                speed: speed,
                timestamp: timestamp,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$RoutePointsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$RoutePointsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutePointsTable,
      RoutePoint,
      $$RoutePointsTableFilterComposer,
      $$RoutePointsTableOrderingComposer,
      $$RoutePointsTableAnnotationComposer,
      $$RoutePointsTableCreateCompanionBuilder,
      $$RoutePointsTableUpdateCompanionBuilder,
      (RoutePoint, $$RoutePointsTableReferences),
      RoutePoint,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SplitPacesTableCreateCompanionBuilder =
    SplitPacesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int kmIndex,
      required int paceSecPerKm,
      required DateTime startTime,
      required DateTime endTime,
    });
typedef $$SplitPacesTableUpdateCompanionBuilder =
    SplitPacesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> kmIndex,
      Value<int> paceSecPerKm,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
    });

final class $$SplitPacesTableReferences
    extends BaseReferences<_$AppDatabase, $SplitPacesTable, SplitPace> {
  $$SplitPacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.splitPaces.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SplitPacesTableFilterComposer
    extends Composer<_$AppDatabase, $SplitPacesTable> {
  $$SplitPacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kmIndex => $composableBuilder(
    column: $table.kmIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitPacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitPacesTable> {
  $$SplitPacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kmIndex => $composableBuilder(
    column: $table.kmIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitPacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitPacesTable> {
  $$SplitPacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kmIndex =>
      $composableBuilder(column: $table.kmIndex, builder: (column) => column);

  GeneratedColumn<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitPacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitPacesTable,
          SplitPace,
          $$SplitPacesTableFilterComposer,
          $$SplitPacesTableOrderingComposer,
          $$SplitPacesTableAnnotationComposer,
          $$SplitPacesTableCreateCompanionBuilder,
          $$SplitPacesTableUpdateCompanionBuilder,
          (SplitPace, $$SplitPacesTableReferences),
          SplitPace,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SplitPacesTableTableManager(_$AppDatabase db, $SplitPacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitPacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitPacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitPacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> kmIndex = const Value.absent(),
                Value<int> paceSecPerKm = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
              }) => SplitPacesCompanion(
                id: id,
                sessionId: sessionId,
                kmIndex: kmIndex,
                paceSecPerKm: paceSecPerKm,
                startTime: startTime,
                endTime: endTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int kmIndex,
                required int paceSecPerKm,
                required DateTime startTime,
                required DateTime endTime,
              }) => SplitPacesCompanion.insert(
                id: id,
                sessionId: sessionId,
                kmIndex: kmIndex,
                paceSecPerKm: paceSecPerKm,
                startTime: startTime,
                endTime: endTime,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitPacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SplitPacesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SplitPacesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SplitPacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitPacesTable,
      SplitPace,
      $$SplitPacesTableFilterComposer,
      $$SplitPacesTableOrderingComposer,
      $$SplitPacesTableAnnotationComposer,
      $$SplitPacesTableCreateCompanionBuilder,
      $$SplitPacesTableUpdateCompanionBuilder,
      (SplitPace, $$SplitPacesTableReferences),
      SplitPace,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String type,
      required String title,
      required String description,
      required DateTime achievedAt,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> type,
      Value<String> title,
      Value<String> description,
      Value<DateTime> achievedAt,
    });

final class $$AchievementsTableReferences
    extends BaseReferences<_$AppDatabase, $AchievementsTable, Achievement> {
  $$AchievementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.achievements.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (Achievement, $$AchievementsTableReferences),
          Achievement,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                sessionId: sessionId,
                type: type,
                title: title,
                description: description,
                achievedAt: achievedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String type,
                required String title,
                required String description,
                required DateTime achievedAt,
              }) => AchievementsCompanion.insert(
                id: id,
                sessionId: sessionId,
                type: type,
                title: title,
                description: description,
                achievedAt: achievedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AchievementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$AchievementsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$AchievementsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (Achievement, $$AchievementsTableReferences),
      Achievement,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TrainingPlansTableCreateCompanionBuilder =
    TrainingPlansCompanion Function({
      Value<int> id,
      required String name,
      required String description,
      required int totalWeeks,
      Value<bool> isBuiltIn,
    });
typedef $$TrainingPlansTableUpdateCompanionBuilder =
    TrainingPlansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<int> totalWeeks,
      Value<bool> isBuiltIn,
    });

final class $$TrainingPlansTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingPlansTable, TrainingPlan> {
  $$TrainingPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrainingDaysTable, List<TrainingDay>>
  _trainingDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trainingDays,
    aliasName: $_aliasNameGenerator(
      db.trainingPlans.id,
      db.trainingDays.planId,
    ),
  );

  $$TrainingDaysTableProcessedTableManager get trainingDaysRefs {
    final manager = $$TrainingDaysTableTableManager(
      $_db,
      $_db.trainingDays,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trainingDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingDaysRefs(
    Expression<bool> Function($$TrainingDaysTableFilterComposer f) f,
  ) {
    final $$TrainingDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingDays,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingDaysTableFilterComposer(
            $db: $db,
            $table: $db.trainingDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWeeks => $composableBuilder(
    column: $table.totalWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  Expression<T> trainingDaysRefs<T extends Object>(
    Expression<T> Function($$TrainingDaysTableAnnotationComposer a) f,
  ) {
    final $$TrainingDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingDays,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingPlansTable,
          TrainingPlan,
          $$TrainingPlansTableFilterComposer,
          $$TrainingPlansTableOrderingComposer,
          $$TrainingPlansTableAnnotationComposer,
          $$TrainingPlansTableCreateCompanionBuilder,
          $$TrainingPlansTableUpdateCompanionBuilder,
          (TrainingPlan, $$TrainingPlansTableReferences),
          TrainingPlan,
          PrefetchHooks Function({bool trainingDaysRefs})
        > {
  $$TrainingPlansTableTableManager(_$AppDatabase db, $TrainingPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> totalWeeks = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => TrainingPlansCompanion(
                id: id,
                name: name,
                description: description,
                totalWeeks: totalWeeks,
                isBuiltIn: isBuiltIn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
                required int totalWeeks,
                Value<bool> isBuiltIn = const Value.absent(),
              }) => TrainingPlansCompanion.insert(
                id: id,
                name: name,
                description: description,
                totalWeeks: totalWeeks,
                isBuiltIn: isBuiltIn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trainingDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (trainingDaysRefs) db.trainingDays],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trainingDaysRefs)
                    await $_getPrefetchedData<
                      TrainingPlan,
                      $TrainingPlansTable,
                      TrainingDay
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingPlansTableReferences
                          ._trainingDaysRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrainingPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).trainingDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrainingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingPlansTable,
      TrainingPlan,
      $$TrainingPlansTableFilterComposer,
      $$TrainingPlansTableOrderingComposer,
      $$TrainingPlansTableAnnotationComposer,
      $$TrainingPlansTableCreateCompanionBuilder,
      $$TrainingPlansTableUpdateCompanionBuilder,
      (TrainingPlan, $$TrainingPlansTableReferences),
      TrainingPlan,
      PrefetchHooks Function({bool trainingDaysRefs})
    >;
typedef $$TrainingDaysTableCreateCompanionBuilder =
    TrainingDaysCompanion Function({
      Value<int> id,
      required int planId,
      required int weekIndex,
      required int dayIndex,
      required String type,
      Value<int?> targetDistanceMeters,
      Value<int?> targetPaceSecPerKm,
      Value<String?> intervals,
    });
typedef $$TrainingDaysTableUpdateCompanionBuilder =
    TrainingDaysCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int> weekIndex,
      Value<int> dayIndex,
      Value<String> type,
      Value<int?> targetDistanceMeters,
      Value<int?> targetPaceSecPerKm,
      Value<String?> intervals,
    });

final class $$TrainingDaysTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingDaysTable, TrainingDay> {
  $$TrainingDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingPlansTable _planIdTable(_$AppDatabase db) =>
      db.trainingPlans.createAlias(
        $_aliasNameGenerator(db.trainingDays.planId, db.trainingPlans.id),
      );

  $$TrainingPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$TrainingPlansTableTableManager(
      $_db,
      $_db.trainingPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrainingDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingDaysTable> {
  $$TrainingDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekIndex => $composableBuilder(
    column: $table.weekIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervals => $composableBuilder(
    column: $table.intervals,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingPlansTableFilterComposer get planId {
    final $$TrainingPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableFilterComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingDaysTable> {
  $$TrainingDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekIndex => $composableBuilder(
    column: $table.weekIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervals => $composableBuilder(
    column: $table.intervals,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingPlansTableOrderingComposer get planId {
    final $$TrainingPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableOrderingComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingDaysTable> {
  $$TrainingDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekIndex =>
      $composableBuilder(column: $table.weekIndex, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervals =>
      $composableBuilder(column: $table.intervals, builder: (column) => column);

  $$TrainingPlansTableAnnotationComposer get planId {
    final $$TrainingPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingDaysTable,
          TrainingDay,
          $$TrainingDaysTableFilterComposer,
          $$TrainingDaysTableOrderingComposer,
          $$TrainingDaysTableAnnotationComposer,
          $$TrainingDaysTableCreateCompanionBuilder,
          $$TrainingDaysTableUpdateCompanionBuilder,
          (TrainingDay, $$TrainingDaysTableReferences),
          TrainingDay,
          PrefetchHooks Function({bool planId})
        > {
  $$TrainingDaysTableTableManager(_$AppDatabase db, $TrainingDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int> weekIndex = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> targetDistanceMeters = const Value.absent(),
                Value<int?> targetPaceSecPerKm = const Value.absent(),
                Value<String?> intervals = const Value.absent(),
              }) => TrainingDaysCompanion(
                id: id,
                planId: planId,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
                type: type,
                targetDistanceMeters: targetDistanceMeters,
                targetPaceSecPerKm: targetPaceSecPerKm,
                intervals: intervals,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required int weekIndex,
                required int dayIndex,
                required String type,
                Value<int?> targetDistanceMeters = const Value.absent(),
                Value<int?> targetPaceSecPerKm = const Value.absent(),
                Value<String?> intervals = const Value.absent(),
              }) => TrainingDaysCompanion.insert(
                id: id,
                planId: planId,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
                type: type,
                targetDistanceMeters: targetDistanceMeters,
                targetPaceSecPerKm: targetPaceSecPerKm,
                intervals: intervals,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$TrainingDaysTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$TrainingDaysTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrainingDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingDaysTable,
      TrainingDay,
      $$TrainingDaysTableFilterComposer,
      $$TrainingDaysTableOrderingComposer,
      $$TrainingDaysTableAnnotationComposer,
      $$TrainingDaysTableCreateCompanionBuilder,
      $$TrainingDaysTableUpdateCompanionBuilder,
      (TrainingDay, $$TrainingDaysTableReferences),
      TrainingDay,
      PrefetchHooks Function({bool planId})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required String conversationId,
      required String role,
      required String content,
      Value<int?> sessionId,
      Value<String?> summaryType,
      required DateTime createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<int?> sessionId,
      Value<String?> summaryType,
      Value<DateTime> createdAt,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryType => $composableBuilder(
    column: $table.summaryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryType => $composableBuilder(
    column: $table.summaryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get summaryType => $composableBuilder(
    column: $table.summaryType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String?> summaryType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                sessionId: sessionId,
                summaryType: summaryType,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conversationId,
                required String role,
                required String content,
                Value<int?> sessionId = const Value.absent(),
                Value<String?> summaryType = const Value.absent(),
                required DateTime createdAt,
              }) => ChatMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                sessionId: sessionId,
                summaryType: summaryType,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$AudienceShoutsTableCreateCompanionBuilder =
    AudienceShoutsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String audienceRole,
      required String personality,
      required String triggerType,
      Value<int?> triggerKm,
      required String content,
      Value<bool> isFavorite,
      required String triggerContext,
      required DateTime createdAt,
    });
typedef $$AudienceShoutsTableUpdateCompanionBuilder =
    AudienceShoutsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> audienceRole,
      Value<String> personality,
      Value<String> triggerType,
      Value<int?> triggerKm,
      Value<String> content,
      Value<bool> isFavorite,
      Value<String> triggerContext,
      Value<DateTime> createdAt,
    });

final class $$AudienceShoutsTableReferences
    extends BaseReferences<_$AppDatabase, $AudienceShoutsTable, AudienceShout> {
  $$AudienceShoutsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.audienceShouts.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudienceFavoritesTable, List<AudienceFavorite>>
  _audienceFavoritesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audienceFavorites,
        aliasName: $_aliasNameGenerator(
          db.audienceShouts.id,
          db.audienceFavorites.representativeShoutId,
        ),
      );

  $$AudienceFavoritesTableProcessedTableManager get audienceFavoritesRefs {
    final manager =
        $$AudienceFavoritesTableTableManager(
          $_db,
          $_db.audienceFavorites,
        ).filter(
          (f) => f.representativeShoutId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _audienceFavoritesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudienceShoutsTableFilterComposer
    extends Composer<_$AppDatabase, $AudienceShoutsTable> {
  $$AudienceShoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get triggerKm => $composableBuilder(
    column: $table.triggerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerContext => $composableBuilder(
    column: $table.triggerContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audienceFavoritesRefs(
    Expression<bool> Function($$AudienceFavoritesTableFilterComposer f) f,
  ) {
    final $$AudienceFavoritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audienceFavorites,
      getReferencedColumn: (t) => t.representativeShoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceFavoritesTableFilterComposer(
            $db: $db,
            $table: $db.audienceFavorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudienceShoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudienceShoutsTable> {
  $$AudienceShoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get triggerKm => $composableBuilder(
    column: $table.triggerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerContext => $composableBuilder(
    column: $table.triggerContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudienceShoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudienceShoutsTable> {
  $$AudienceShoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get triggerKm =>
      $composableBuilder(column: $table.triggerKm, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerContext => $composableBuilder(
    column: $table.triggerContext,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audienceFavoritesRefs<T extends Object>(
    Expression<T> Function($$AudienceFavoritesTableAnnotationComposer a) f,
  ) {
    final $$AudienceFavoritesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.audienceFavorites,
          getReferencedColumn: (t) => t.representativeShoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AudienceFavoritesTableAnnotationComposer(
                $db: $db,
                $table: $db.audienceFavorites,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudienceShoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudienceShoutsTable,
          AudienceShout,
          $$AudienceShoutsTableFilterComposer,
          $$AudienceShoutsTableOrderingComposer,
          $$AudienceShoutsTableAnnotationComposer,
          $$AudienceShoutsTableCreateCompanionBuilder,
          $$AudienceShoutsTableUpdateCompanionBuilder,
          (AudienceShout, $$AudienceShoutsTableReferences),
          AudienceShout,
          PrefetchHooks Function({bool sessionId, bool audienceFavoritesRefs})
        > {
  $$AudienceShoutsTableTableManager(
    _$AppDatabase db,
    $AudienceShoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudienceShoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudienceShoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudienceShoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> audienceRole = const Value.absent(),
                Value<String> personality = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<int?> triggerKm = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> triggerContext = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudienceShoutsCompanion(
                id: id,
                sessionId: sessionId,
                audienceRole: audienceRole,
                personality: personality,
                triggerType: triggerType,
                triggerKm: triggerKm,
                content: content,
                isFavorite: isFavorite,
                triggerContext: triggerContext,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String audienceRole,
                required String personality,
                required String triggerType,
                Value<int?> triggerKm = const Value.absent(),
                required String content,
                Value<bool> isFavorite = const Value.absent(),
                required String triggerContext,
                required DateTime createdAt,
              }) => AudienceShoutsCompanion.insert(
                id: id,
                sessionId: sessionId,
                audienceRole: audienceRole,
                personality: personality,
                triggerType: triggerType,
                triggerKm: triggerKm,
                content: content,
                isFavorite: isFavorite,
                triggerContext: triggerContext,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudienceShoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, audienceFavoritesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audienceFavoritesRefs) db.audienceFavorites,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$AudienceShoutsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$AudienceShoutsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audienceFavoritesRefs)
                        await $_getPrefetchedData<
                          AudienceShout,
                          $AudienceShoutsTable,
                          AudienceFavorite
                        >(
                          currentTable: table,
                          referencedTable: $$AudienceShoutsTableReferences
                              ._audienceFavoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudienceShoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).audienceFavoritesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.representativeShoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AudienceShoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudienceShoutsTable,
      AudienceShout,
      $$AudienceShoutsTableFilterComposer,
      $$AudienceShoutsTableOrderingComposer,
      $$AudienceShoutsTableAnnotationComposer,
      $$AudienceShoutsTableCreateCompanionBuilder,
      $$AudienceShoutsTableUpdateCompanionBuilder,
      (AudienceShout, $$AudienceShoutsTableReferences),
      AudienceShout,
      PrefetchHooks Function({bool sessionId, bool audienceFavoritesRefs})
    >;
typedef $$AudienceFavoritesTableCreateCompanionBuilder =
    AudienceFavoritesCompanion Function({
      Value<int> id,
      required String audienceRole,
      required String personality,
      Value<int?> representativeShoutId,
      required DateTime createdAt,
    });
typedef $$AudienceFavoritesTableUpdateCompanionBuilder =
    AudienceFavoritesCompanion Function({
      Value<int> id,
      Value<String> audienceRole,
      Value<String> personality,
      Value<int?> representativeShoutId,
      Value<DateTime> createdAt,
    });

final class $$AudienceFavoritesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AudienceFavoritesTable,
          AudienceFavorite
        > {
  $$AudienceFavoritesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudienceShoutsTable _representativeShoutIdTable(_$AppDatabase db) =>
      db.audienceShouts.createAlias(
        $_aliasNameGenerator(
          db.audienceFavorites.representativeShoutId,
          db.audienceShouts.id,
        ),
      );

  $$AudienceShoutsTableProcessedTableManager? get representativeShoutId {
    final $_column = $_itemColumn<int>('representative_shout_id');
    if ($_column == null) return null;
    final manager = $$AudienceShoutsTableTableManager(
      $_db,
      $_db.audienceShouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _representativeShoutIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudienceFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $AudienceFavoritesTable> {
  $$AudienceFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AudienceShoutsTableFilterComposer get representativeShoutId {
    final $$AudienceShoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.representativeShoutId,
      referencedTable: $db.audienceShouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceShoutsTableFilterComposer(
            $db: $db,
            $table: $db.audienceShouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudienceFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudienceFavoritesTable> {
  $$AudienceFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudienceShoutsTableOrderingComposer get representativeShoutId {
    final $$AudienceShoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.representativeShoutId,
      referencedTable: $db.audienceShouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceShoutsTableOrderingComposer(
            $db: $db,
            $table: $db.audienceShouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudienceFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudienceFavoritesTable> {
  $$AudienceFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AudienceShoutsTableAnnotationComposer get representativeShoutId {
    final $$AudienceShoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.representativeShoutId,
      referencedTable: $db.audienceShouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudienceShoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.audienceShouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudienceFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudienceFavoritesTable,
          AudienceFavorite,
          $$AudienceFavoritesTableFilterComposer,
          $$AudienceFavoritesTableOrderingComposer,
          $$AudienceFavoritesTableAnnotationComposer,
          $$AudienceFavoritesTableCreateCompanionBuilder,
          $$AudienceFavoritesTableUpdateCompanionBuilder,
          (AudienceFavorite, $$AudienceFavoritesTableReferences),
          AudienceFavorite,
          PrefetchHooks Function({bool representativeShoutId})
        > {
  $$AudienceFavoritesTableTableManager(
    _$AppDatabase db,
    $AudienceFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudienceFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudienceFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudienceFavoritesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> audienceRole = const Value.absent(),
                Value<String> personality = const Value.absent(),
                Value<int?> representativeShoutId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudienceFavoritesCompanion(
                id: id,
                audienceRole: audienceRole,
                personality: personality,
                representativeShoutId: representativeShoutId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String audienceRole,
                required String personality,
                Value<int?> representativeShoutId = const Value.absent(),
                required DateTime createdAt,
              }) => AudienceFavoritesCompanion.insert(
                id: id,
                audienceRole: audienceRole,
                personality: personality,
                representativeShoutId: representativeShoutId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudienceFavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({representativeShoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (representativeShoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.representativeShoutId,
                                referencedTable:
                                    $$AudienceFavoritesTableReferences
                                        ._representativeShoutIdTable(db),
                                referencedColumn:
                                    $$AudienceFavoritesTableReferences
                                        ._representativeShoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AudienceFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudienceFavoritesTable,
      AudienceFavorite,
      $$AudienceFavoritesTableFilterComposer,
      $$AudienceFavoritesTableOrderingComposer,
      $$AudienceFavoritesTableAnnotationComposer,
      $$AudienceFavoritesTableCreateCompanionBuilder,
      $$AudienceFavoritesTableUpdateCompanionBuilder,
      (AudienceFavorite, $$AudienceFavoritesTableReferences),
      AudienceFavorite,
      PrefetchHooks Function({bool representativeShoutId})
    >;
typedef $$AudienceUnlocksTableCreateCompanionBuilder =
    AudienceUnlocksCompanion Function({
      Value<int> id,
      required String audienceRole,
      required DateTime unlockedAt,
      required int unlockedAtRunCount,
      Value<bool> hasSeenAnimation,
    });
typedef $$AudienceUnlocksTableUpdateCompanionBuilder =
    AudienceUnlocksCompanion Function({
      Value<int> id,
      Value<String> audienceRole,
      Value<DateTime> unlockedAt,
      Value<int> unlockedAtRunCount,
      Value<bool> hasSeenAnimation,
    });

class $$AudienceUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $AudienceUnlocksTable> {
  $$AudienceUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAtRunCount => $composableBuilder(
    column: $table.unlockedAtRunCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSeenAnimation => $composableBuilder(
    column: $table.hasSeenAnimation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudienceUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $AudienceUnlocksTable> {
  $$AudienceUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAtRunCount => $composableBuilder(
    column: $table.unlockedAtRunCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSeenAnimation => $composableBuilder(
    column: $table.hasSeenAnimation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudienceUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudienceUnlocksTable> {
  $$AudienceUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audienceRole => $composableBuilder(
    column: $table.audienceRole,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlockedAtRunCount => $composableBuilder(
    column: $table.unlockedAtRunCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSeenAnimation => $composableBuilder(
    column: $table.hasSeenAnimation,
    builder: (column) => column,
  );
}

class $$AudienceUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudienceUnlocksTable,
          AudienceUnlock,
          $$AudienceUnlocksTableFilterComposer,
          $$AudienceUnlocksTableOrderingComposer,
          $$AudienceUnlocksTableAnnotationComposer,
          $$AudienceUnlocksTableCreateCompanionBuilder,
          $$AudienceUnlocksTableUpdateCompanionBuilder,
          (
            AudienceUnlock,
            BaseReferences<
              _$AppDatabase,
              $AudienceUnlocksTable,
              AudienceUnlock
            >,
          ),
          AudienceUnlock,
          PrefetchHooks Function()
        > {
  $$AudienceUnlocksTableTableManager(
    _$AppDatabase db,
    $AudienceUnlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudienceUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudienceUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudienceUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> audienceRole = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> unlockedAtRunCount = const Value.absent(),
                Value<bool> hasSeenAnimation = const Value.absent(),
              }) => AudienceUnlocksCompanion(
                id: id,
                audienceRole: audienceRole,
                unlockedAt: unlockedAt,
                unlockedAtRunCount: unlockedAtRunCount,
                hasSeenAnimation: hasSeenAnimation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String audienceRole,
                required DateTime unlockedAt,
                required int unlockedAtRunCount,
                Value<bool> hasSeenAnimation = const Value.absent(),
              }) => AudienceUnlocksCompanion.insert(
                id: id,
                audienceRole: audienceRole,
                unlockedAt: unlockedAt,
                unlockedAtRunCount: unlockedAtRunCount,
                hasSeenAnimation: hasSeenAnimation,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudienceUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudienceUnlocksTable,
      AudienceUnlock,
      $$AudienceUnlocksTableFilterComposer,
      $$AudienceUnlocksTableOrderingComposer,
      $$AudienceUnlocksTableAnnotationComposer,
      $$AudienceUnlocksTableCreateCompanionBuilder,
      $$AudienceUnlocksTableUpdateCompanionBuilder,
      (
        AudienceUnlock,
        BaseReferences<_$AppDatabase, $AudienceUnlocksTable, AudienceUnlock>,
      ),
      AudienceUnlock,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db, _db.runSessions);
  $$RoutePointsTableTableManager get routePoints =>
      $$RoutePointsTableTableManager(_db, _db.routePoints);
  $$SplitPacesTableTableManager get splitPaces =>
      $$SplitPacesTableTableManager(_db, _db.splitPaces);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$TrainingPlansTableTableManager get trainingPlans =>
      $$TrainingPlansTableTableManager(_db, _db.trainingPlans);
  $$TrainingDaysTableTableManager get trainingDays =>
      $$TrainingDaysTableTableManager(_db, _db.trainingDays);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$AudienceShoutsTableTableManager get audienceShouts =>
      $$AudienceShoutsTableTableManager(_db, _db.audienceShouts);
  $$AudienceFavoritesTableTableManager get audienceFavorites =>
      $$AudienceFavoritesTableTableManager(_db, _db.audienceFavorites);
  $$AudienceUnlocksTableTableManager get audienceUnlocks =>
      $$AudienceUnlocksTableTableManager(_db, _db.audienceUnlocks);
}
