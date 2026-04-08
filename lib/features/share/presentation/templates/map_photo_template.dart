import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/share_card_config.dart';
import '../../domain/share_card_data.dart';
import '../widgets/map_trajectory_view.dart';
import '../widgets/watermark_footer.dart';

/// 地图底图模板 — 以真实地图瓦片为背景，叠加轨迹 + 数据
class MapPhotoTemplate extends StatelessWidget {
  final ShareCardData data;
  final ShareCardConfig config;
  final double cardWidth;
  final double cardHeight;

  const MapPhotoTemplate({
    super.key,
    required this.data,
    required this.config,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final data = this.data;
    final config = this.config;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: SolrunColors.darkBg,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // 1. 地图背景（不可交互）
          Positioned.fill(
            child: MapTrajectoryView(data: data, config: config),
          ),

          // 2. 顶部渐变遮罩（提升文字可读性）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. 底部渐变遮罩（提升数据可读性）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // 4. 顶部头信息（始终显示头像+昵称）
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: _buildHeader(data),
          ),

          // 5. 底部数据叠加层
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: _buildBottomData(context, data, config),
          ),
        ],
      ),
    );
  }

  /// 构建顶部头信息（头像 + 昵称 + 日期）
  Widget _buildHeader(ShareCardData data) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white24,
          backgroundImage: data.avatarPath != null
              ? FileImage(File(data.avatarPath!))
              : null,
          child: data.avatarPath == null
              ? const Icon(Icons.person, size: 18, color: Colors.white70)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            data.nickname,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          data.dateFormatted,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  /// 构建底部数据层
  Widget _buildBottomData(BuildContext context, ShareCardData data, ShareCardConfig config) {
    final s = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 距离大数字
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              data.distanceKm,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 56,
                color: Colors.white,
                height: 1.0,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 8),
                  Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                s.share_kilometer,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  decoration: TextDecoration.none,
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 指标行：配速 | 时长 | 卡路里
        Row(
          children: [
            _buildMetric(s.share_pace, data.paceFormatted),
            _buildDivider(),
            _buildMetric(s.share_duration, data.durationFormatted),
            _buildDivider(),
            _buildMetric(s.share_calories, data.caloriesFormatted),
          ],
        ),

        // 水印区域（观众喊话 + 品牌行）
        if (config.showWatermark) ...[
          const SizedBox(height: 8),
          WatermarkFooter(
            config: config,
            data: data,
            shoutBottomSpacing: 12,
            shoutColor: Colors.white.withValues(alpha: 0.6),
            shoutHorizontalPadding: 4,
            cityWeatherColor: Colors.white.withValues(alpha: 0.4),
            sloganColor: Colors.white.withValues(alpha: 0.4),
            layout: WatermarkLayout.spaceBetween,
          ),
        ],
      ],
    );
  }

  /// 单个指标
  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SolrunColors.accent,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 指标间分隔线
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
