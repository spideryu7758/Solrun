import '../../data/database.dart';

/// CSV 格式导出器
/// 生成汇总数据 + 分公里配速明细
class CsvExporter {
  /// 生成 CSV 字符串
  static String export(RunSession session, List<SplitPace> splits) {
    final buf = StringBuffer();

    // 汇总信息
    buf.writeln('# Solrun 跑步记录');
    buf.writeln('名称,${session.autoName}');
    buf.writeln('日期,${session.startTime.toIso8601String()}');
    buf.writeln('距离(km),${(session.distanceMeters / 1000).toStringAsFixed(2)}');
    buf.writeln('时长(秒),${session.durationSeconds}');
    buf.writeln('均配速(秒/km),${session.avgPaceSecPerKm}');
    buf.writeln('最快配速(秒/km),${session.bestPaceSecPerKm}');
    buf.writeln('���路里(kcal),${session.caloriesKcal}');
    buf.writeln('海拔爬升(m),${session.elevationGainMeters.toStringAsFixed(1)}');
    buf.writeln();

    // 分公里配速明细
    if (splits.isNotEmpty) {
      buf.writeln('# 分公里配速');
      buf.writeln('公里,配速(秒/km),开始时间,结束时间');
      for (final s in splits) {
        buf.writeln('${s.kmIndex},${s.paceSecPerKm},${s.startTime.toIso8601String()},${s.endTime.toIso8601String()}');
      }
    }

    return buf.toString();
  }
}
