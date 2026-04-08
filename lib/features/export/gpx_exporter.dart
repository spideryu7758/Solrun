import '../../data/database.dart';

/// GPX 格式导出器
/// 生成标准 GPS Exchange Format XML，可导入 Strava / Garmin Connect
class GpxExporter {
  /// 生成 GPX XML 字符串
  /// [session] 跑步记录
  /// [points] 轨迹点（按 orderIndex 排序）
  static String export(RunSession session, List<RoutePoint> points) {
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buf.writeln('<gpx version="1.1" creator="Solrun"');
    buf.writeln('  xmlns="http://www.topografix.com/GPX/1/1"');
    buf.writeln('  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    buf.writeln('  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');
    buf.writeln('  <metadata>');
    buf.writeln('    <name>${_xmlEscape(session.autoName)}</name>');
    buf.writeln('    <time>${session.startTime.toUtc().toIso8601String()}</time>');
    buf.writeln('  </metadata>');
    buf.writeln('  <trk>');
    buf.writeln('    <name>${_xmlEscape(session.autoName)}</name>');
    buf.writeln('    <trkseg>');

    for (final p in points) {
      buf.write('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
      if (p.altitude != null) {
        buf.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
      }
      buf.write('<time>${p.timestamp.toUtc().toIso8601String()}</time>');
      buf.writeln('</trkpt>');
    }

    buf.writeln('    </trkseg>');
    buf.writeln('  </trk>');
    buf.writeln('</gpx>');

    return buf.toString();
  }

  static String _xmlEscape(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
