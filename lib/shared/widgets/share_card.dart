import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../features/share/presentation/share_preview_screen.dart';

/// 分享入口 — 弹出新的分享预览页
class ShareCardHelper {
  static Future<void> share(
    BuildContext context, {
    required RunSession session,
    required List<RoutePoint> points,
    List<SplitPace> splits = const [],
  }) async {
    if (!context.mounted) return;

    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => SharePreviewScreen(sessionId: session.id),
    ));
  }
}
