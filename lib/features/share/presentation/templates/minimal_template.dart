import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/share_card_config.dart';
import '../../domain/share_card_data.dart';
import '../painters/heatmap_route_painter.dart';
import '../widgets/map_trajectory_view.dart';
import '../widgets/watermark_footer.dart';

/// 极简模板 — 大数字 + 轨迹，去掉一切多余装饰
class MinimalTemplate extends StatelessWidget {
  final ShareCardData data;
  final ShareCardConfig config;
  final double cardWidth;
  final double cardHeight;

  const MinimalTemplate({
    super.key,
    required this.data,
    required this.config,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(color: SolrunColors.darkBg),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 头像 + 昵称
          if (config.showHeader)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: SolrunColors.darkCard,
                  backgroundImage: data.avatarPath != null
                      ? FileImage(File(data.avatarPath!))
                      : null,
                  child: data.avatarPath == null
                      ? const Icon(
                          Icons.person,
                          size: 18,
                          color: SolrunColors.darkMuted,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  data.nickname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SolrunColors.darkText,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),

          if (config.showHeader) const Spacer(flex: 1),

          if (!config.showHeader) const Spacer(flex: 2),

          // 距离大数字
          Text(
            data.distanceKm,
            style: const TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 80,
              color: SolrunColors.accent,
              height: 1.0,
              decoration: TextDecoration.none,
            ),
          ),

          // KM 标签
          const Text(
            'KM',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              color: SolrunColors.darkMuted,
              letterSpacing: 6,
              decoration: TextDecoration.none,
            ),
          ),

          if (config.showHeader) ...[
            const SizedBox(height: 8),
            Text(
              data.dateFormatted,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: SolrunColors.darkMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ],

          // 留白
          const Spacer(flex: 1),

          // 轨迹区域（占据卡片主体空间）
          Expanded(flex: 6, child: _buildTrajectory()),

          const SizedBox(height: 16),

          // 水印区域（观众喊话 + 品牌行）
          if (config.showWatermark)
            WatermarkFooter(
              config: config,
              data: data,
              logoFontSize: 14,
              sloganColor: SolrunColors.darkMuted.withValues(alpha: 0.6),
              sloganSpacing: 8,
            ),
        ],
      ),
    );
  }

  /// 轨迹区域：支持地图底图切换
  Widget _buildTrajectory() {
    // 地图底图模式
    if (config.showMapTiles && data.points.length >= 2) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: MapTrajectoryView(
          data: data,
          config: config,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    // 默认 Canvas 模式
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SolrunColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: HeatmapRoutePainter(
          points: data.points,
          segmentColors: config.showHeatmap ? data.segmentColors : null,
          mergedSegments: config.showHeatmap ? data.mergedSegments : null,
        ),
        size: Size.infinite,
      ),
    );
  }
}
