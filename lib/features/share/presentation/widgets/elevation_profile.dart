import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// 海拔剖面面积图（Canvas 绘制，用于分享卡片）
class ElevationProfile extends StatelessWidget {
  final List<double> altitudes;
  final double height;

  const ElevationProfile({
    super.key,
    required this.altitudes,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    if (altitudes.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ElevationPainter(altitudes: altitudes),
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  final List<double> altitudes;

  _ElevationPainter({required this.altitudes});

  @override
  void paint(Canvas canvas, Size size) {
    if (altitudes.length < 2) return;

    // 中位数滤波平滑（窗口 5）
    final smoothed = _medianFilter(altitudes, 5);

    final minAlt = smoothed.reduce(math.min);
    final maxAlt = smoothed.reduce(math.max);
    final range = maxAlt - minAlt;
    final effectiveRange = range < 1 ? 1.0 : range;
    final padding = effectiveRange * 0.1;

    // 构建路径
    final path = Path();
    final step = smoothed.length > 300 ? smoothed.length ~/ 300 : 1;

    for (int i = 0; i < smoothed.length; i += step) {
      final x = i / (smoothed.length - 1) * size.width;
      final y = size.height - ((smoothed[i] - minAlt + padding) / (effectiveRange + 2 * padding)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // 确保最后一个点
    final lastX = size.width;
    final lastY = size.height - ((smoothed.last - minAlt + padding) / (effectiveRange + 2 * padding)) * size.height;
    path.lineTo(lastX, lastY);

    // 描边线
    final linePaint = Paint()
      ..color = SolrunColors.accent.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // 填充面积（渐变）
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          SolrunColors.accent.withValues(alpha: 0.25),
          SolrunColors.accent.withValues(alpha: 0.02),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 标注最高/最低海拔
    final textStyle = TextStyle(
      fontSize: 8,
      color: SolrunColors.darkMuted,
    );
    _drawLabel(canvas, '${maxAlt.toStringAsFixed(0)}m', Offset(4, 2), textStyle);
    _drawLabel(canvas, '${minAlt.toStringAsFixed(0)}m', Offset(4, size.height - 12), textStyle);
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  /// 中位数滤波
  List<double> _medianFilter(List<double> data, int windowSize) {
    if (data.length < windowSize) return List.from(data);
    final half = windowSize ~/ 2;
    final result = <double>[];
    for (int i = 0; i < data.length; i++) {
      final start = (i - half).clamp(0, data.length - 1);
      final end = (i + half + 1).clamp(0, data.length);
      final window = data.sublist(start, end).toList()..sort();
      result.add(window[window.length ~/ 2]);
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _ElevationPainter oldDelegate) =>
      oldDelegate.altitudes != altitudes;
}
