import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../data/database.dart';

/// 配速热力 Canvas 轨迹绘制器
/// 支持单色和多色段两种模式
class HeatmapRoutePainter extends CustomPainter {
  final List<RoutePoint> points;
  final List<Color>? segmentColors; // null 则用单色
  final List<({List<int> indices, Color color})>? mergedSegments;

  HeatmapRoutePainter({
    required this.points,
    this.segmentColors,
    this.mergedSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // 计算 bounding box
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latPad = (maxLat - minLat) * 0.15;
    final lngPad = (maxLng - minLng) * 0.15;
    minLat -= latPad; maxLat += latPad;
    minLng -= lngPad; maxLng += lngPad;

    if (maxLat - minLat < 0.0001) { maxLat += 0.0005; minLat -= 0.0005; }
    if (maxLng - minLng < 0.0001) { maxLng += 0.0005; minLng -= 0.0005; }

    Offset toPixel(double lat, double lng) {
      final x = (lng - minLng) / (maxLng - minLng) * size.width;
      final y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height;
      return Offset(x, y);
    }

    // 降采样
    final step = points.length > 500 ? points.length ~/ 500 : 1;

    // 如果有合并的热力段，按段绘制
    if (mergedSegments != null && mergedSegments!.isNotEmpty) {
      _drawHeatmapSegments(canvas, size, toPixel, step);
    } else {
      _drawMonochrome(canvas, size, toPixel, step);
    }

    // 起点绿 + 终点黄
    final first = toPixel(points.first.latitude, points.first.longitude);
    final last = toPixel(points.last.latitude, points.last.longitude);
    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = const Color(0xFF47FF47);
    canvas.drawCircle(first, 5, dotPaint);
    dotPaint.color = SolrunColors.accent;
    canvas.drawCircle(last, 5, dotPaint);
  }

  /// 热力多色段绘制（性能优化：合并 glow 为单次绘制）
  void _drawHeatmapSegments(
    Canvas canvas, Size size,
    Offset Function(double lat, double lng) toPixel,
    int step,
  ) {
    // 先绘制统一 glow 底层（单次绘制，大幅减少 GPU 开销）
    final glowPath = Path();
    bool glowStarted = false;
    for (final p in points) {
      final px = toPixel(p.latitude, p.longitude);
      if (!glowStarted) {
        glowPath.moveTo(px.dx, px.dy);
        glowStarted = true;
      } else {
        glowPath.lineTo(px.dx, px.dy);
      }
    }
    if (glowStarted) {
      final glowPaint = Paint()
        ..color = const Color(0x4DFFFFFF) // 白色半透明统一发光
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(glowPath, glowPaint);
    }

    // 再逐段绘制有色主线
    for (final seg in mergedSegments!) {
      final path = Path();
      bool started = false;

      for (final idx in seg.indices) {
        if (idx >= points.length) continue;
        final p = toPixel(points[idx].latitude, points[idx].longitude);
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }

      if (!started) continue;

      final paint = Paint()
        ..color = seg.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, paint);
    }
  }

  /// 单色绘制（经典模式回退）
  void _drawMonochrome(
    Canvas canvas, Size size,
    Offset Function(double lat, double lng) toPixel,
    int step,
  ) {
    final path = Path();
    final first = toPixel(points.first.latitude, points.first.longitude);
    path.moveTo(first.dx, first.dy);

    for (int i = step; i < points.length; i += step) {
      final p = toPixel(points[i].latitude, points[i].longitude);
      path.lineTo(p.dx, p.dy);
    }
    final last = toPixel(points.last.latitude, points.last.longitude);
    path.lineTo(last.dx, last.dy);

    // 发光
    final glowPaint = Paint()
      ..color = SolrunColors.accent.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    final paint = Paint()
      ..color = SolrunColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeatmapRoutePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.segmentColors != segmentColors ||
      oldDelegate.mergedSegments != mergedSegments;
}
