import '../../../data/database.dart';
import '../../../shared/utils/run_format_utils.dart';

/// 跑者画像数据
class RunnerProfile {
  // ── 总览 ──
  final int totalRuns;
  final double totalDistanceKm;
  final int totalDurationSec;
  final int streakDays;
  final int daysSinceLastRun;

  // ── 最佳/最差记录 ──
  final int bestPaceSecPerKm;
  final int worstPaceSecPerKm;
  final double longestRunKm;
  final double shortestRunKm;
  final int? best5kTimeSec;
  final int? best10kTimeSec;

  // ── 近期趋势（近 4 周） ──
  final List<double> weeklyDistances;
  final List<int> weeklyCounts;
  final int recentAvgPaceSecPerKm;
  final double recentAvgDistanceKm;
  final String paceTrend; // improving / stable / declining

  // ── 月度统计 ──
  final double monthDistanceKm;
  final int monthRuns;
  final int monthAvgPaceSecPerKm;

  // ── 习惯特征 ──
  final String preferredTime;
  final String preferredDistance;
  final double avgRunsPerWeek;

  /// 是否有历史数据
  final bool hasHistory;

  const RunnerProfile({
    required this.totalRuns,
    required this.totalDistanceKm,
    required this.totalDurationSec,
    required this.streakDays,
    required this.daysSinceLastRun,
    required this.bestPaceSecPerKm,
    required this.worstPaceSecPerKm,
    required this.longestRunKm,
    required this.shortestRunKm,
    this.best5kTimeSec,
    this.best10kTimeSec,
    required this.weeklyDistances,
    required this.weeklyCounts,
    required this.recentAvgPaceSecPerKm,
    required this.recentAvgDistanceKm,
    required this.paceTrend,
    required this.monthDistanceKm,
    required this.monthRuns,
    required this.monthAvgPaceSecPerKm,
    required this.preferredTime,
    required this.preferredDistance,
    required this.avgRunsPerWeek,
    required this.hasHistory,
  });
}

/// 跑者画像构建器（静态工具类）
class RunnerProfileBuilder {
  RunnerProfileBuilder._();

  /// 从历史跑步记录构建跑者画像
  static RunnerProfile build(
    List<RunSession> sessions, {
    List<SplitPace>? allSplits,
  }) {
    if (sessions.isEmpty) return _emptyProfile();

    // 按 startTime 排序（最新在前）
    final sorted = List<RunSession>.from(sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final now = DateTime.now();

    final overview = _calcOverview(sorted, now);
    final records = _calcBestRecords(sorted, allSplits);
    final trend = _calcWeeklyTrend(sorted, now);
    final month = _calcMonthlyStats(sorted, now);
    final habits = _calcHabits(sorted, trend.weeklyCounts);

    return RunnerProfile(
      // 总览
      totalRuns: overview.totalRuns,
      totalDistanceKm: overview.totalDistanceKm,
      totalDurationSec: overview.totalDurationSec,
      streakDays: overview.streakDays,
      daysSinceLastRun: overview.daysSinceLastRun,
      // 记录
      bestPaceSecPerKm: records.bestPace,
      worstPaceSecPerKm: records.worstPace,
      longestRunKm: records.longestKm,
      shortestRunKm: records.shortestKm,
      best5kTimeSec: records.best5k,
      best10kTimeSec: records.best10k,
      // 趋势
      weeklyDistances: trend.weeklyDistances,
      weeklyCounts: trend.weeklyCounts,
      recentAvgPaceSecPerKm: trend.avgPace,
      recentAvgDistanceKm: trend.avgDistance,
      paceTrend: _calcPaceTrend(sorted, now),
      // 月度
      monthDistanceKm: month.distanceKm,
      monthRuns: month.runs,
      monthAvgPaceSecPerKm: month.avgPace,
      // 习惯
      preferredTime: habits.preferredTime,
      preferredDistance: habits.preferredDistance,
      avgRunsPerWeek: habits.avgRunsPerWeek,
      hasHistory: true,
    );
  }

  /// 格式化为 prompt 文本
  static String formatForPrompt(RunnerProfile profile, {bool isEn = false}) {
    if (isEn) return _formatForPromptEn(profile);

    if (!profile.hasHistory) {
      return '【跑者档案】\n新跑者，暂无历史数据。';
    }

    final buf = StringBuffer();
    buf.writeln('【跑者档案】');
    buf.writeln('- 累计跑步 ${profile.totalRuns} 次，'
        '总距离 ${profile.totalDistanceKm.toStringAsFixed(1)}km');
    buf.writeln('- 当前连续跑步 ${profile.streakDays} 天');
    buf.writeln('- 历史最佳配速 '
        '${RunFormatUtils.formatPace(profile.bestPaceSecPerKm)}/km，'
        '最差 ${RunFormatUtils.formatPace(profile.worstPaceSecPerKm)}/km');

    if (profile.best5kTimeSec != null) {
      buf.writeln('- 5K 最佳��绩 '
          '${RunFormatUtils.formatDuration(profile.best5kTimeSec!)}');
    }
    if (profile.best10kTimeSec != null) {
      buf.writeln('- 10K 最佳成绩 '
          '${RunFormatUtils.formatDuration(profile.best10kTimeSec!)}');
    }

    final weeklyStr = profile.weeklyDistances
        .map((d) => '${d.toStringAsFixed(1)}km')
        .join(' → ');
    buf.writeln('- 近 4 周周跑量��$weeklyStr（本周进行中）');
    buf.writeln('- 近 4 周均配速 '
        '${RunFormatUtils.formatPace(profile.recentAvgPaceSecPerKm)}/km，'
        '配速趋势：${_trendLabel(profile.paceTrend)}');

    buf.writeln('- 本月已跑 ${profile.monthRuns} 次共 '
        '${profile.monthDistanceKm.toStringAsFixed(1)}km，'
        '月均配速 '
        '${RunFormatUtils.formatPace(profile.monthAvgPaceSecPerKm)}/km');

    final timeZh = _timeZhLabel(profile.preferredTime);
    final timeRange = _timeRangeLabel(profile.preferredTime);
    buf.writeln('- 最常在$timeZh $timeRange跑步，'
        '常跑距离${profile.preferredDistance}');
    buf.writeln('- 周均跑步 '
        '${profile.avgRunsPerWeek.toStringAsFixed(1)} 次');

    if (profile.daysSinceLastRun > 3) {
      buf.writeln('- 距上次跑步已 ${profile.daysSinceLastRun} 天');
    }

    return buf.toString();
  }

  /// 英文版 prompt 格式化
  static String _formatForPromptEn(RunnerProfile profile) {
    if (!profile.hasHistory) {
      return '[Runner Profile]\nNew runner, no historical data.';
    }

    final buf = StringBuffer();
    buf.writeln('[Runner Profile]');
    buf.writeln('- ${profile.totalRuns} runs, '
        'total ${profile.totalDistanceKm.toStringAsFixed(1)}km');
    buf.writeln('- Current streak: ${profile.streakDays} days');
    buf.writeln('- Best pace '
        '${RunFormatUtils.formatPace(profile.bestPaceSecPerKm)}/km, '
        'worst ${RunFormatUtils.formatPace(profile.worstPaceSecPerKm)}/km');

    if (profile.best5kTimeSec != null) {
      buf.writeln('- 5K PB: '
          '${RunFormatUtils.formatDuration(profile.best5kTimeSec!)}');
    }
    if (profile.best10kTimeSec != null) {
      buf.writeln('- 10K PB: '
          '${RunFormatUtils.formatDuration(profile.best10kTimeSec!)}');
    }

    final weeklyStr = profile.weeklyDistances
        .map((d) => '${d.toStringAsFixed(1)}km')
        .join(' → ');
    buf.writeln('- Last 4 weeks volume: $weeklyStr (current week ongoing)');
    buf.writeln('- Recent avg pace '
        '${RunFormatUtils.formatPace(profile.recentAvgPaceSecPerKm)}/km, '
        'trend: ${_trendLabel(profile.paceTrend, isEn: true)}');

    buf.writeln('- This month: ${profile.monthRuns} runs / '
        '${profile.monthDistanceKm.toStringAsFixed(1)}km, '
        'avg pace '
        '${RunFormatUtils.formatPace(profile.monthAvgPaceSecPerKm)}/km');

    final timeEn = _timeEnLabel(profile.preferredTime);
    final timeRange = _timeRangeLabel(profile.preferredTime);
    buf.writeln('- Usually runs in the $timeEn ($timeRange), '
        'typical distance ${profile.preferredDistance}');
    buf.writeln('- Avg ${profile.avgRunsPerWeek.toStringAsFixed(1)} runs/week');

    if (profile.daysSinceLastRun > 3) {
      buf.writeln('- ${profile.daysSinceLastRun} days since last run');
    }

    return buf.toString();
  }

  // ── 总览计算 ──

  static ({
    int totalRuns,
    double totalDistanceKm,
    int totalDurationSec,
    int streakDays,
    int daysSinceLastRun,
  }) _calcOverview(List<RunSession> sorted, DateTime now) {
    return (
      totalRuns: sorted.length,
      totalDistanceKm:
          sorted.fold<double>(0, (s, r) => s + r.distanceMeters) / 1000,
      totalDurationSec:
          sorted.fold<int>(0, (s, r) => s + r.durationSeconds),
      streakDays: _calcStreakDays(sorted),
      daysSinceLastRun:
          now.difference(sorted.first.startTime).inDays,
    );
  }

  // ── 最佳/最差记录 ──

  static ({
    int bestPace,
    int worstPace,
    double longestKm,
    double shortestKm,
    int? best5k,
    int? best10k,
  }) _calcBestRecords(List<RunSession> sorted, List<SplitPace>? allSplits) {
    final paces = sorted.map((r) => r.avgPaceSecPerKm).toList();
    final distances = sorted.map((r) => r.distanceMeters / 1000).toList();

    return (
      bestPace: paces.reduce((a, b) => a < b ? a : b),
      worstPace: paces.reduce((a, b) => a > b ? a : b),
      longestKm: distances.reduce((a, b) => a > b ? a : b),
      shortestKm: distances.reduce((a, b) => a < b ? a : b),
      best5k: allSplits != null
          ? _findBestDistanceTime(sorted, allSplits, 4.8, 5.2)
          : null,
      best10k: allSplits != null
          ? _findBestDistanceTime(sorted, allSplits, 9.8, 10.2)
          : null,
    );
  }

  // ── 近 4 周趋势 ──

  static ({
    List<double> weeklyDistances,
    List<int> weeklyCounts,
    int avgPace,
    double avgDistance,
  }) _calcWeeklyTrend(List<RunSession> sorted, DateTime now) {
    final weeklyDistances = <double>[];
    final weeklyCounts = <int>[];
    var totalDist = 0.0;
    var totalDur = 0;
    var totalRuns = 0;

    for (int w = 0; w < 4; w++) {
      final weekEnd = now.subtract(Duration(days: w * 7));
      final weekStart = now.subtract(Duration(days: (w + 1) * 7));
      final weekSessions = sorted
          .where((r) =>
              r.startTime.isAfter(weekStart) &&
              !r.startTime.isAfter(weekEnd))
          .toList();

      final dist =
          weekSessions.fold<double>(0, (s, r) => s + r.distanceMeters) / 1000;
      final dur =
          weekSessions.fold<int>(0, (s, r) => s + r.durationSeconds);

      weeklyDistances.add(dist);
      weeklyCounts.add(weekSessions.length);
      totalDist += dist;
      totalDur += dur;
      totalRuns += weekSessions.length;
    }

    return (
      weeklyDistances: weeklyDistances,
      weeklyCounts: weeklyCounts,
      avgPace: totalDist > 0 ? (totalDur / totalDist).round() : 0,
      avgDistance: totalRuns > 0 ? totalDist / totalRuns : 0.0,
    );
  }

  // ��─ 月度统计 ──

  static ({
    double distanceKm,
    int runs,
    int avgPace,
  }) _calcMonthlyStats(List<RunSession> sorted, DateTime now) {
    final monthStart = DateTime(now.year, now.month, 1);
    final monthSessions =
        sorted.where((r) => r.startTime.isAfter(monthStart)).toList();
    final distKm =
        monthSessions.fold<double>(0, (s, r) => s + r.distanceMeters) / 1000;
    final totalDur =
        monthSessions.fold<int>(0, (s, r) => s + r.durationSeconds);
    return (
      distanceKm: distKm,
      runs: monthSessions.length,
      avgPace: distKm > 0 ? (totalDur / distKm).round() : 0,
    );
  }

  // ── 习惯特征 ──

  static ({
    String preferredTime,
    String preferredDistance,
    double avgRunsPerWeek,
  }) _calcHabits(List<RunSession> sorted, List<int> weeklyCounts) {
    final hours = sorted.map((r) => r.startTime.hour).toList();
    final distances = sorted.map((r) => r.distanceMeters / 1000).toList();
    final weeksWithRuns = weeklyCounts.where((c) => c > 0).length;
    final totalWeeklyRuns = weeklyCounts.fold<int>(0, (a, b) => a + b);

    return (
      preferredTime: _categorizeMax(
        hours,
        _timeClassifier,
        fallback: 'none',
        postProcess: (key) => key, // 存储语言中立 key，由 formatForPrompt 翻译
      ),
      preferredDistance: _categorizeMax(
        distances,
        _distanceClassifier,
        fallback: 'none',
      ),
      avgRunsPerWeek:
          weeksWithRuns > 0 ? totalWeeklyRuns / weeksWithRuns : 0.0,
    );
  }

  // ── 通用分桶函数 ──

  /// 将数据列表按分类器分桶，返回出现次数最多的类别
  static String _categorizeMax<T>(
    List<T> data,
    String Function(T) classifier, {
    required String fallback,
    String Function(String)? postProcess,
  }) {
    if (data.isEmpty) return fallback;
    final buckets = <String, int>{};
    for (final item in data) {
      final label = classifier(item);
      buckets[label] = (buckets[label] ?? 0) + 1;
    }
    final winner =
        buckets.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return postProcess != null ? postProcess(winner) : winner;
  }

  /// 时段分类器（返回语言中立 key，由 _timeLabel 翻译）
  static String _timeClassifier(int hour) {
    if (hour < 5) return 'dawn';
    if (hour < 10) return 'morning';
    if (hour < 12) return 'forenoon';
    if (hour < 14) return 'noon';
    if (hour < 18) return 'afternoon';
    if (hour < 22) return 'evening';
    return 'lateNight';
  }

  /// 距离分类器（中英文通用数值标签 + 最后一档中英双版本）
  static String _distanceClassifier(double km) {
    if (km < 3) return '< 3km';
    if (km < 5) return '3-5km';
    if (km < 7) return '5-7km';
    if (km < 10) return '7-10km';
    if (km < 15) return '10-15km';
    if (km < 21) return '15-21km';
    return '21km+';
  }

  // ── 其他辅助方法 ──

  static RunnerProfile _emptyProfile() {
    return const RunnerProfile(
      totalRuns: 0,
      totalDistanceKm: 0,
      totalDurationSec: 0,
      streakDays: 0,
      daysSinceLastRun: 0,
      bestPaceSecPerKm: 0,
      worstPaceSecPerKm: 0,
      longestRunKm: 0,
      shortestRunKm: 0,
      weeklyDistances: [0, 0, 0, 0],
      weeklyCounts: [0, 0, 0, 0],
      recentAvgPaceSecPerKm: 0,
      recentAvgDistanceKm: 0,
      paceTrend: 'stable',
      monthDistanceKm: 0,
      monthRuns: 0,
      monthAvgPaceSecPerKm: 0,
      preferredTime: 'none',
      preferredDistance: 'none',
      avgRunsPerWeek: 0,
      hasHistory: false,
    );
  }

  /// 计算连续跑步天数
  static int _calcStreakDays(List<RunSession> sorted) {
    if (sorted.isEmpty) return 0;
    int streak = 0;
    DateTime? prevDate;
    for (final session in sorted) {
      final date = DateTime(
          session.startTime.year, session.startTime.month, session.startTime.day);
      if (prevDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterdayDate = todayDate.subtract(const Duration(days: 1));
        if (date == todayDate || date == yesterdayDate) {
          streak = 1;
          prevDate = date;
        } else {
          break;
        }
      } else {
        final diff = prevDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          prevDate = date;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  /// 在指定距离范围内查找最佳用时
  static int? _findBestDistanceTime(
    List<RunSession> sessions,
    List<SplitPace> allSplits,
    double minKm,
    double maxKm,
  ) {
    int? bestTime;
    for (final session in sessions) {
      final distKm = session.distanceMeters / 1000;
      if (distKm < minKm || distKm > maxKm) continue;
      final splits = allSplits
          .where((s) => s.sessionId == session.id)
          .toList()
        ..sort((a, b) => a.kmIndex.compareTo(b.kmIndex));
      if (splits.isEmpty) continue;
      final totalSec =
          splits.last.endTime.difference(splits.first.startTime).inSeconds;
      if (bestTime == null || totalSec < bestTime) {
        bestTime = totalSec;
      }
    }
    return bestTime;
  }

  /// 配速趋势（近 2 周 vs 前 2 ��）
  static String _calcPaceTrend(List<RunSession> sorted, DateTime now) {
    final midPoint = now.subtract(const Duration(days: 14));
    final recent =
        sorted.where((r) => r.startTime.isAfter(midPoint)).toList();
    final older =
        sorted.where((r) => !r.startTime.isAfter(midPoint)).toList();

    if (recent.isEmpty || older.isEmpty) return 'stable';

    final recentAvg =
        recent.fold<int>(0, (s, r) => s + r.avgPaceSecPerKm) / recent.length;
    final olderAvg =
        older.fold<int>(0, (s, r) => s + r.avgPaceSecPerKm) / older.length;

    final diff = olderAvg - recentAvg; // 正值 = 配速变快
    if (diff > 10) return 'improving';
    if (diff < -10) return 'declining';
    return 'stable';
  }

  /// 时段 key → 时间范围标签
  static String _timeRangeLabel(String key) {
    return switch (key) {
      'dawn' => '0:00-5:00',
      'morning' => '6:00-9:00',
      'forenoon' => '10:00-11:00',
      'noon' => '12:00-13:00',
      'afternoon' => '14:00-17:00',
      'evening' => '18:00-21:00',
      'lateNight' => '22:00-23:00',
      _ => '',
    };
  }

  /// 时段 key → 中文名称
  static String _timeZhLabel(String key) {
    return switch (key) {
      'dawn' => '凌晨',
      'morning' => '早晨',
      'forenoon' => '上午',
      'noon' => '中午',
      'afternoon' => '下午',
      'evening' => '傍晚',
      'lateNight' => '深夜',
      _ => key,
    };
  }

  /// 时段 key → 英文名称
  static String _timeEnLabel(String key) {
    return switch (key) {
      'dawn' => 'dawn',
      'morning' => 'morning',
      'forenoon' => 'late morning',
      'noon' => 'midday',
      'afternoon' => 'afternoon',
      'evening' => 'evening',
      'lateNight' => 'late night',
      _ => key,
    };
  }

  static String _trendLabel(String trend, {bool isEn = false}) {
    if (isEn) {
      return switch (trend) {
        'improving' => 'improving',
        'declining' => 'declining',
        _ => 'stable',
      };
    }
    return switch (trend) {
      'improving' => '进步中',
      'declining' => '下滑中',
      _ => '稳定',
    };
  }
}
