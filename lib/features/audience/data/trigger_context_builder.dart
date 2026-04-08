import '../../../data/database.dart';
import '../../../shared/utils/run_format_utils.dart';
import 'runner_profile_builder.dart';

/// 触发类型枚举
enum TriggerType {
  start, // 开跑
  splitKm, // 公里分割（每整公里）
  split5km, // 5 公里节点
  paceAlert, // 配速异常
  finish, // 跑步结束
}

/// 触发上下文数据
class TriggerContext {
  final TriggerType triggerType;

  // 当前数据
  final int currentKm;
  final int currentKmPaceSecPerKm;
  final int currentAvgPaceSecPerKm;
  final double currentDistanceKm;
  final int currentDurationSec;

  // 对比数据
  final String? vsLastKm;
  final String? vsHistoryAvg;
  final String? vsBestPace;
  final String? vsSameDistanceBest;

  // 分公里配速列表
  final List<int> splitPacesSecPerKm;

  // 环境
  final String timeOfDay;
  final int? temperature;
  final String? weather;
  final String? holiday;

  const TriggerContext({
    required this.triggerType,
    required this.currentKm,
    required this.currentKmPaceSecPerKm,
    required this.currentAvgPaceSecPerKm,
    required this.currentDistanceKm,
    required this.currentDurationSec,
    this.vsLastKm,
    this.vsHistoryAvg,
    this.vsBestPace,
    this.vsSameDistanceBest,
    required this.splitPacesSecPerKm,
    required this.timeOfDay,
    this.temperature,
    this.weather,
    this.holiday,
  });

  /// 触发时的公里数
  int? get triggerKm {
    switch (triggerType) {
      case TriggerType.splitKm:
      case TriggerType.split5km:
        return currentKm;
      default:
        return null;
    }
  }

  /// 格式化为 prompt 文本
  ///
  /// [isEn] 为 true 时输出英文版
  String formatForPrompt({bool isEn = false}) {
    final buf = StringBuffer();

    if (isEn) {
      buf.writeln('[Current Race Status]');

      buf.writeln('- Trigger: ${_triggerTypeLabelEn(triggerType)}'
          '${triggerKm != null ? " (km $triggerKm)" : ""}');

      if (currentKmPaceSecPerKm > 0) {
        buf.writeln('- This km pace: '
            '${RunFormatUtils.formatPace(currentKmPaceSecPerKm)}/km'
            '${vsLastKm != null ? " ($vsLastKm)" : ""}');
      }
      if (currentAvgPaceSecPerKm > 0) {
        buf.writeln('- Current avg pace: '
            '${RunFormatUtils.formatPace(currentAvgPaceSecPerKm)}/km'
            '${vsHistoryAvg != null ? " ($vsHistoryAvg)" : ""}');
      }
      buf.writeln('- Distance: '
          '${currentDistanceKm.toStringAsFixed(2)}km, '
          'elapsed ${RunFormatUtils.formatDuration(currentDurationSec)}');

      if (vsBestPace != null) {
        buf.writeln('- vs personal best pace: $vsBestPace');
      }
      if (vsSameDistanceBest != null) {
        buf.writeln('- vs best at same distance: $vsSameDistanceBest');
      }

      if (splitPacesSecPerKm.isNotEmpty) {
        buf.write('- Split paces: ');
        buf.write(splitPacesSecPerKm.map(RunFormatUtils.formatPace).join(' → '));
        if (splitPacesSecPerKm.length >= 2) {
          final last = splitPacesSecPerKm.last;
          final prev = splitPacesSecPerKm[splitPacesSecPerKm.length - 2];
          if (last < prev) {
            buf.write(' (speeding up)');
          } else if (last > prev) {
            buf.write(' (slowing down)');
          }
        }
        buf.writeln();
      }

      buf.writeln('- Time of day: $timeOfDay');
      if (weather != null) buf.writeln('- Weather: $weather');
      if (temperature != null) buf.writeln('- Temperature: $temperature°C');
      if (holiday != null) buf.writeln('- Holiday: $holiday');
    } else {
      buf.writeln('【当前比赛实况】');

      buf.writeln('- 触发：${_triggerTypeLabelZh(triggerType)}'
          '${triggerKm != null ? "（第 $triggerKm 公里）" : ""}');

      if (currentKmPaceSecPerKm > 0) {
        buf.writeln('- 本公里配速：'
            '${RunFormatUtils.formatPace(currentKmPaceSecPerKm)}/km'
            '${vsLastKm != null ? "（$vsLastKm）" : ""}');
      }
      if (currentAvgPaceSecPerKm > 0) {
        buf.writeln('- 本次平均配速：'
            '${RunFormatUtils.formatPace(currentAvgPaceSecPerKm)}/km'
            '${vsHistoryAvg != null ? "（$vsHistoryAvg）" : ""}');
      }
      buf.writeln('- 已跑距离：'
          '${currentDistanceKm.toStringAsFixed(2)}km，'
          '用时 ${RunFormatUtils.formatDuration(currentDurationSec)}');

      if (vsBestPace != null) {
        buf.writeln('- 与历史最佳配速差距：$vsBestPace');
      }
      if (vsSameDistanceBest != null) {
        buf.writeln('- 与同距离历史最佳对比：$vsSameDistanceBest');
      }

      if (splitPacesSecPerKm.isNotEmpty) {
        buf.write('- 分公里配速：');
        buf.write(splitPacesSecPerKm.map(RunFormatUtils.formatPace).join(' → '));
        if (splitPacesSecPerKm.length >= 2) {
          final last = splitPacesSecPerKm.last;
          final prev = splitPacesSecPerKm[splitPacesSecPerKm.length - 2];
          if (last < prev) {
            buf.write('（逐公里加速中）');
          } else if (last > prev) {
            buf.write('（最近一公里掉速）');
          }
        }
        buf.writeln();
      }

      buf.writeln('- 时段：$timeOfDay');
      if (weather != null) buf.writeln('- 天气：$weather');
      if (temperature != null) buf.writeln('- 气温：$temperature°C');
      if (holiday != null) buf.writeln('- 节日：$holiday');
    }

    return buf.toString();
  }

  /// 中文触发类型标签
  static String _triggerTypeLabelZh(TriggerType type) {
    return switch (type) {
      TriggerType.start => '开跑',
      TriggerType.splitKm => '公里分割',
      TriggerType.split5km => '5 公里节点',
      TriggerType.paceAlert => '配速异常',
      TriggerType.finish => '跑步结束',
    };
  }

  /// 英文触发类型标签
  static String _triggerTypeLabelEn(TriggerType type) {
    return switch (type) {
      TriggerType.start => 'run started',
      TriggerType.splitKm => 'km split',
      TriggerType.split5km => '5km milestone',
      TriggerType.paceAlert => 'pace alert',
      TriggerType.finish => 'run finished',
    };
  }
}

/// 触发上下文构建器
class TriggerContextBuilder {
  TriggerContextBuilder._();

  /// 构建开始跑步触发上下文
  static TriggerContext buildStartContext() {
    return TriggerContext(
      triggerType: TriggerType.start,
      currentKm: 0,
      currentKmPaceSecPerKm: 0,
      currentAvgPaceSecPerKm: 0,
      currentDistanceKm: 0,
      currentDurationSec: 0,
      splitPacesSecPerKm: [],
      timeOfDay: _timeOfDay(DateTime.now()),
    );
  }

  /// 构建公里分割触发上下文
  static TriggerContext buildSplitKmContext({
    required int completedKm,
    required int kmPaceSecPerKm,
    required int avgPaceSecPerKm,
    required double distanceKm,
    required int durationSec,
    required List<SplitPace> splits,
    RunnerProfile? profile,
  }) {
    final splitPaces = splits.map((s) => s.paceSecPerKm).toList();

    // 对比上一公里（语言中立格式：+/-秒 vs prev km）
    String? vsLastKm;
    if (splits.length >= 2) {
      final prevPace = splits[splits.length - 2].paceSecPerKm;
      final diff = kmPaceSecPerKm - prevPace;
      if (diff > 0) {
        vsLastKm = '+${diff}s vs prev km';
      } else if (diff < 0) {
        vsLastKm = '${diff}s vs prev km';
      } else {
        vsLastKm = 'same as prev km';
      }
    }

    return TriggerContext(
      triggerType:
          completedKm % 5 == 0 ? TriggerType.split5km : TriggerType.splitKm,
      currentKm: completedKm,
      currentKmPaceSecPerKm: kmPaceSecPerKm,
      currentAvgPaceSecPerKm: avgPaceSecPerKm,
      currentDistanceKm: distanceKm,
      currentDurationSec: durationSec,
      vsLastKm: vsLastKm,
      vsHistoryAvg: _compareWithHistoryAvg(profile, avgPaceSecPerKm),
      vsBestPace: _compareWithBestPace(profile, avgPaceSecPerKm),
      splitPacesSecPerKm: splitPaces,
      timeOfDay: _timeOfDay(DateTime.now()),
    );
  }

  /// 构建配速异常触发上下文
  static TriggerContext buildPaceAlertContext({
    required int currentPaceSecPerKm,
    required int avgPaceSecPerKm,
    required double distanceKm,
    required int durationSec,
    required List<SplitPace> splits,
  }) {
    final diff = currentPaceSecPerKm - avgPaceSecPerKm;
    final direction = diff > 0 ? 'slower' : 'faster';
    final percent = avgPaceSecPerKm > 0
        ? (diff.abs() / avgPaceSecPerKm * 100).round()
        : 0;

    return TriggerContext(
      triggerType: TriggerType.paceAlert,
      currentKm: distanceKm.floor(),
      currentKmPaceSecPerKm: currentPaceSecPerKm,
      currentAvgPaceSecPerKm: avgPaceSecPerKm,
      currentDistanceKm: distanceKm,
      currentDurationSec: durationSec,
      vsHistoryAvg: '$direction by ${diff.abs()}s ($percent% off)',
      splitPacesSecPerKm: splits.map((s) => s.paceSecPerKm).toList(),
      timeOfDay: _timeOfDay(DateTime.now()),
    );
  }

  /// 构建跑步结束触发上下文
  static TriggerContext buildFinishContext({
    required RunSession session,
    required List<SplitPace> splits,
    RunnerProfile? profile,
  }) {
    final distanceKm = session.distanceMeters / 1000;

    // 同距离最佳对比（语言中立格式）
    String? vsSameDistanceBest;
    if (profile != null && profile.hasHistory) {
      final diff = session.avgPaceSecPerKm - profile.bestPaceSecPerKm;
      if (diff < 0) {
        vsSameDistanceBest = 'new PB! ${-diff}s faster';
      }
    }

    return TriggerContext(
      triggerType: TriggerType.finish,
      currentKm: distanceKm.floor(),
      currentKmPaceSecPerKm: 0,
      currentAvgPaceSecPerKm: session.avgPaceSecPerKm,
      currentDistanceKm: distanceKm,
      currentDurationSec: session.durationSeconds,
      vsHistoryAvg:
          _compareWithHistoryAvg(profile, session.avgPaceSecPerKm),
      vsSameDistanceBest: vsSameDistanceBest,
      splitPacesSecPerKm: splits.map((s) => s.paceSecPerKm).toList(),
      timeOfDay: _timeOfDay(session.startTime),
    );
  }

  // ── 通用对比方法（消除重复） ──

  /// 与历史均值对比（语言中立格式）
  static String? _compareWithHistoryAvg(
    RunnerProfile? profile,
    int currentPace,
  ) {
    if (profile == null ||
        !profile.hasHistory ||
        profile.recentAvgPaceSecPerKm <= 0) {
      return null;
    }
    final diff = currentPace - profile.recentAvgPaceSecPerKm;
    if (diff > 0) return '+${diff}s vs avg';
    if (diff < 0) return '${diff}s vs avg';
    return 'same as avg';
  }

  /// 与历史最佳对比（语言中立格式）
  static String? _compareWithBestPace(
    RunnerProfile? profile,
    int currentPace,
  ) {
    if (profile == null ||
        !profile.hasHistory ||
        profile.bestPaceSecPerKm <= 0) {
      return null;
    }
    final diff = currentPace - profile.bestPaceSecPerKm;
    return '${diff > 0 ? "+" : ""}${diff}s/km vs PB';
  }

  /// 时段描述（语言中立，24h 时间格式 LLM 可理解）
  static String _timeOfDay(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
