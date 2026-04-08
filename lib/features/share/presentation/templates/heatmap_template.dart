import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/share_card_config.dart';
import '../../domain/share_card_data.dart';
import '../painters/heatmap_route_painter.dart';
import '../widgets/map_trajectory_view.dart';
import '../widgets/split_pace_chart.dart';
import '../widgets/elevation_profile.dart';
import '../widgets/watermark_footer.dart';

/// 热力强调分享卡片模板
/// 轨迹占更大比例，数据紧凑单行排列，accent 色彩更激进
class HeatmapTemplate extends StatelessWidget {
  final ShareCardData data;
  final ShareCardConfig config;
  final double cardWidth;
  final double cardHeight;

  const HeatmapTemplate({
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
      decoration: BoxDecoration(
        color: SolrunColors.darkBg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 紧凑头部
            if (config.showHeader) ...[
              _buildCompactHeader(),
              const SizedBox(height: 10),
            ],

            // 距离 + 单位（紧凑，不独占大量垂直空间）
            _buildDistanceRow(),
            const SizedBox(height: 10),

            // 轨迹图区域（占据更大比例）
            Expanded(flex: 5, child: _buildTrajectory(context)),

            // 配速图紧跟轨迹下方
            if (config.showPaceChart && data.splits.isNotEmpty) ...[
              const SizedBox(height: 10),
              SplitPaceChart(splits: data.splits, height: 55),
            ],

            // 海拔剖面
            if (config.showElevationProfile && data.altitudes.length >= 2) ...[
              const SizedBox(height: 6),
              ElevationProfile(altitudes: data.altitudes, height: 40),
            ],

            // 紧凑单行数据
            if (config.showDataGrid) ...[
              const SizedBox(height: 12),
              _buildCompactDataRow(context),
            ],

            // 水印区域（观众喊话 + 品牌行）
            if (config.showWatermark) ...[
              const SizedBox(height: 4),
              WatermarkFooter(
                config: config,
                data: data,
                shoutBottomSpacing: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 紧凑头部：小头像 + 昵称 + Solrun（单行）
  Widget _buildCompactHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: SolrunColors.darkCard,
          backgroundImage: data.avatarPath != null
              ? FileImage(File(data.avatarPath!))
              : null,
          child: data.avatarPath == null
              ? const Icon(Icons.person, size: 16, color: SolrunColors.darkMuted)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${data.nickname} · ${data.dateFormatted}',
            style: const TextStyle(
              fontSize: 11,
              color: SolrunColors.darkMuted,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Text(
          'Solrun',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 15,
            color: SolrunColors.accent,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  /// 距离行：数字 + "km" 一体化
  Widget _buildDistanceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          data.distanceKm,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 48,
            color: SolrunColors.darkText,
            letterSpacing: 2,
            decoration: TextDecoration.none,
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'km',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 20,
            color: SolrunColors.accent,
            letterSpacing: 1,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  /// 轨迹图区域（热力始终开启）
  Widget _buildTrajectory(BuildContext context) {
    // 地图底图模式
    if (config.showMapTiles && data.points.length >= 2) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SolrunColors.accent.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: MapTrajectoryView(
          data: data,
          config: config,
          borderRadius: BorderRadius.circular(11),
        ),
      );
    }

    // 默认 Canvas 模式
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SolrunColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        // 热力模板加 accent 色细边框
        border: Border.all(
          color: SolrunColors.accent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: data.points.length >= 2
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11), // 减 1px 避免边框溢出
              child: CustomPaint(
                painter: HeatmapRoutePainter(
                  points: data.points,
                  // 热力模板始终使用热力段着色
                  mergedSegments: config.showHeatmap
                      ? data.mergedSegments
                      : null,
                ),
                size: Size.infinite,
              ),
            )
          : Center(
              child: Text(
                S.of(context)!.share_noRouteData,
                style: TextStyle(
                  color: SolrunColors.darkMuted,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
    );
  }

  /// 紧凑单行数据：距离 | 配速 | 时长 | 卡路里
  Widget _buildCompactDataRow(BuildContext context) {
    final s = S.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: SolrunColors.darkCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _compactDataItem(s.share_distance, data.distanceKm, 'km'),
          _verticalDivider(),
          _compactDataItem(s.share_pace, data.paceFormatted, null),
          _verticalDivider(),
          _compactDataItem(s.share_duration, data.durationFormatted, null),
          _verticalDivider(),
          _compactDataItem(s.share_calories, data.caloriesFormatted, null),
        ],
      ),
    );
  }

  /// 紧凑数据项
  Widget _compactDataItem(String label, String value, String? unit) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SolrunColors.accent,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 9,
                    color: SolrunColors.darkMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: SolrunColors.darkMuted,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 竖分割线
  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: SolrunColors.darkBorder,
    );
  }
}
