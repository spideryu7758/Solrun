import '../../../data/database.dart';
import '../../../shared/utils/run_format_utils.dart';

/// 构建 AI 总结的跑步数据上下文
class ChatContextBuilder {
  ChatContextBuilder._();

  /// 将跑步数据格式化为上下文文本
  static String formatRunContext(RunSession session, {List<SplitPace>? splits, bool isEn = false}) {
    final buf = StringBuffer();
    if (isEn) {
      buf.writeln('[Run Record]');
      buf.writeln('Name: ${session.autoName}');
      buf.writeln('Date: ${_formatDate(session.startTime)}');
      buf.writeln('Distance: ${(session.distanceMeters / 1000).toStringAsFixed(2)} km');
      buf.writeln('Duration: ${RunFormatUtils.formatDuration(session.durationSeconds)}');
      buf.writeln('Avg Pace: ${RunFormatUtils.formatPace(session.avgPaceSecPerKm)}/km');
      buf.writeln('Best Pace: ${RunFormatUtils.formatPace(session.bestPaceSecPerKm)}/km');
      buf.writeln('Calories: ${session.caloriesKcal} kcal');
      buf.writeln('Elevation Gain: ${session.elevationGainMeters.toStringAsFixed(1)} m');

      if (splits != null && splits.isNotEmpty) {
        buf.writeln('\n[Split Pace]');
        for (final s in splits) {
          buf.writeln('  km ${s.kmIndex + 1}: ${RunFormatUtils.formatPace(s.paceSecPerKm)}/km');
        }
      }
    } else {
      buf.writeln('【跑步记录】');
      buf.writeln('名称: ${session.autoName}');
      buf.writeln('日期: ${_formatDate(session.startTime)}');
      buf.writeln('距离: ${(session.distanceMeters / 1000).toStringAsFixed(2)} km');
      buf.writeln('时长: ${RunFormatUtils.formatDuration(session.durationSeconds)}');
      buf.writeln('均配速: ${RunFormatUtils.formatPace(session.avgPaceSecPerKm)}/km');
      buf.writeln('最佳配速: ${RunFormatUtils.formatPace(session.bestPaceSecPerKm)}/km');
      buf.writeln('卡路里: ${session.caloriesKcal} kcal');
      buf.writeln('累计爬升: ${session.elevationGainMeters.toStringAsFixed(1)} m');

      if (splits != null && splits.isNotEmpty) {
        buf.writeln('\n【分公里配速】');
        for (final s in splits) {
          buf.writeln('  第 ${s.kmIndex + 1} km: ${RunFormatUtils.formatPace(s.paceSecPerKm)}/km');
        }
      }
    }

    return buf.toString();
  }

  /// 将多条跑步记录格式化为汇总上下文
  static String formatMultiRunContext(List<RunSession> sessions, String period, {bool isEn = false}) {
    if (isEn) {
      if (sessions.isEmpty) return '[$period] No run records';
    } else {
      if (sessions.isEmpty) return '【$period】无跑步记录';
    }

    final totalDist = sessions.fold<double>(0, (s, r) => s + r.distanceMeters) / 1000;
    final totalDur = sessions.fold<int>(0, (s, r) => s + r.durationSeconds);
    final avgPace = totalDist > 0 ? (totalDur / totalDist).round() : 0;
    final totalCal = sessions.fold<int>(0, (s, r) => s + r.caloriesKcal);

    final buf = StringBuffer();
    if (isEn) {
      buf.writeln('[$period Summary]');
      buf.writeln('Runs: ${sessions.length}');
      buf.writeln('Total Distance: ${totalDist.toStringAsFixed(2)} km');
      buf.writeln('Total Duration: ${RunFormatUtils.formatDuration(totalDur)}');
      buf.writeln('Avg Pace: ${RunFormatUtils.formatPace(avgPace)}/km');
      buf.writeln('Total Calories: $totalCal kcal');

      final bestDist = sessions.reduce((a, b) => a.distanceMeters > b.distanceMeters ? a : b);
      buf.writeln('\nLongest Run: ${(bestDist.distanceMeters / 1000).toStringAsFixed(2)} km (${bestDist.autoName})');

      final bestPace = sessions.reduce((a, b) => a.avgPaceSecPerKm < b.avgPaceSecPerKm ? a : b);
      buf.writeln('Fastest Pace: ${RunFormatUtils.formatPace(bestPace.avgPaceSecPerKm)}/km (${bestPace.autoName})');
    } else {
      buf.writeln('【$period汇总】');
      buf.writeln('跑步次数: ${sessions.length} 次');
      buf.writeln('总距离: ${totalDist.toStringAsFixed(2)} km');
      buf.writeln('总时长: ${RunFormatUtils.formatDuration(totalDur)}');
      buf.writeln('均配速: ${RunFormatUtils.formatPace(avgPace)}/km');
      buf.writeln('总卡路里: $totalCal kcal');

      final bestDist = sessions.reduce((a, b) => a.distanceMeters > b.distanceMeters ? a : b);
      buf.writeln('\n最长距离: ${(bestDist.distanceMeters / 1000).toStringAsFixed(2)} km (${bestDist.autoName})');

      final bestPace = sessions.reduce((a, b) => a.avgPaceSecPerKm < b.avgPaceSecPerKm ? a : b);
      buf.writeln('最快配速: ${RunFormatUtils.formatPace(bestPace.avgPaceSecPerKm)}/km (${bestPace.autoName})');
    }

    return buf.toString();
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
