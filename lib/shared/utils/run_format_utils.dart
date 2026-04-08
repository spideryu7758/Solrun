/// 跑步数据格式化工具
class RunFormatUtils {
  RunFormatUtils._();

  /// 格式化时长（秒 → "X 小时 X 分 X 秒" 或 "X 分 X 秒"）
  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '$h 小时 $m 分 $s 秒';
    return '$m 分 $s 秒';
  }

  /// 格式化配速（秒/公里 → "M'SS\""）
  static String formatPace(int secPerKm) {
    if (secPerKm <= 0) return "0'00\"";
    final min = secPerKm ~/ 60;
    final sec = secPerKm % 60;
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }
}
