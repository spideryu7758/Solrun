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

/// 经典分享卡片模板
/// 布局：头部 → 轨迹图 → 距离大字 → 配速图 → 海拔 → 数据网格 → 水印
class ClassicTemplate extends StatelessWidget {
  final ShareCardData data;
  final ShareCardConfig config;
  final double cardWidth;
  final double cardHeight;

  const ClassicTemplate({
    super.key,
    required this.data,
    required this.config,
    required this.cardWidth,
    required this.cardHeight,
  });

  /// 是否为紧凑布局（1:1 正方形 / 3:4 竖版也可能触发）
  bool get _compact => cardHeight <= 420;

  /// 估算当前配置下非弹性内容的总高度
  /// 用于判断是否会溢出（轨迹区至少需要 30px）
  bool get _willOverflow {
    final c = _compact;
    double h = c ? 28.0 : 40.0; // padding
    if (config.showHeader) h += 40 + (c ? 8 : 16);
    h += c ? 10.0 : 20.0; // 轨迹后间距
    h += (c ? 48.0 : 64.0) + 16.0; // 距离 + 公里
    if (config.showPaceChart && data.splits.isNotEmpty) {
      h += (c ? 45.0 : 60.0) + (c ? 8 : 12);
    }
    if (config.showElevationProfile && data.altitudes.length >= 2) {
      h += (c ? 35.0 : 45.0) + (c ? 6 : 8);
    }
    if (config.showDataGrid) h += (c ? 80.0 : 100.0) + (c ? 8 : 16);
    if (config.showWatermark) h += 14 + (c ? 6 : 12);
    return cardHeight - h < 30;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(color: SolrunColors.darkBg),
      child: _willOverflow
          ? _buildOverflowWarning(context)
          : _buildContent(context),
    );
  }

  /// 内容溢出时的友好提示
  Widget _buildOverflowWarning(BuildContext context) {
    final s = S.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 32, color: SolrunColors.darkMuted),
            const SizedBox(height: 12),
            Text(
              s.share_overflowWarning,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: SolrunColors.darkMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 正常内容布局
  Widget _buildContent(BuildContext context) {
    final s = S.of(context)!;
    final pad = _compact ? 14.0 : 20.0;
    final gap = _compact ? 8.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          // 头部：头像 + 昵称/日期 + Solrun logo
          if (config.showHeader) ...[_buildHeader(), SizedBox(height: gap)],

          // 轨迹图区域（占据大部分空间）
          Expanded(child: _buildTrajectory(context)),
          SizedBox(height: _compact ? 10.0 : 20.0),

          // 距离大字
          _buildDistance(),
          const SizedBox(height: 2),
          Text(
            s.share_kilometer,
            style: TextStyle(
              fontSize: 12,
              color: SolrunColors.darkMuted,
              letterSpacing: 3,
              decoration: TextDecoration.none,
            ),
          ),

          // 分公里配速图
          if (config.showPaceChart && data.splits.isNotEmpty) ...[
            const SizedBox(height: 8),
            SplitPaceChart(
              splits: data.splits,
              height: _compact ? 45 : 60,
              dataEntertainment: config.showDataEntertainment,
            ),
          ],

          // 海拔剖面
          if (config.showElevationProfile && data.altitudes.length >= 2) ...[
            const SizedBox(height: 6),
            ElevationProfile(
              altitudes: data.altitudes,
              height: _compact ? 35 : 45,
            ),
          ],

          // 数据网格
          if (config.showDataGrid) ...[
            SizedBox(height: _compact ? 8.0 : 16.0),
            _buildDataGrid(context),
          ],

          // 水印区域（观众喊话 + 品牌行）
          if (config.showWatermark) ...[
            SizedBox(height: _compact ? 4 : 8),
            WatermarkFooter(
              config: config,
              data: data,
              shoutBottomSpacing: _compact ? 6 : 12,
            ),
          ],
        ],
      ),
    );
  }

  /// 头部：头像 + 昵称/日期 + Solrun logo
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: SolrunColors.darkCard,
          backgroundImage: data.avatarPath != null
              ? FileImage(File(data.avatarPath!))
              : null,
          child: data.avatarPath == null
              ? const Icon(
                  Icons.person,
                  size: 22,
                  color: SolrunColors.darkMuted,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.nickname,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: SolrunColors.darkText,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                data.dateFormatted,
                style: const TextStyle(
                  fontSize: 11,
                  color: SolrunColors.darkMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Solrun',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 18,
            color: SolrunColors.accent,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  /// 轨迹图区域
  Widget _buildTrajectory(BuildContext context) {
    // 地图底图模式：使用 FlutterMap 渲染真实瓦片
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
      child: data.points.length >= 2
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: HeatmapRoutePainter(
                  points: data.points,
                  // 热力模式传入合并段，否则单色
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

  /// 距离大字
  Widget _buildDistance() {
    return Text(
      data.distanceKm,
      style: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: _compact ? 48 : 64,
        color: SolrunColors.darkText,
        letterSpacing: 2,
        decoration: TextDecoration.none,
        height: 1,
      ),
    );
  }

  /// 2x2 数据网格
  Widget _buildDataGrid(BuildContext context) {
    final s = S.of(context)!;
    final vPad = _compact ? 8.0 : 12.0;
    final fontSize = _compact ? 14.0 : 16.0;
    final divH = _compact ? 24.0 : 32.0;
    final pace = config.showDataEntertainment
        ? data.entertainmentPaceFormatted
        : data.paceFormatted;

    return Container(
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: 8),
      decoration: BoxDecoration(
        color: SolrunColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _dataItem(s.share_pace, pace, fontSize),
              _divider(divH),
              _dataItem(s.share_duration, data.durationFormatted, fontSize),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: _compact ? 4.0 : 8.0),
            child: Divider(height: 1, color: SolrunColors.darkBorder),
          ),
          Row(
            children: [
              _dataItem(s.share_calories, data.caloriesFormatted, fontSize),
              _divider(divH),
              _dataItem(
                s.share_elevationGain,
                data.elevationFormatted,
                fontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 单个数据项
  Widget _dataItem(String label, String value, double fontSize) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: SolrunColors.accent,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: SolrunColors.darkMuted,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 数据项间的竖分割线
  Widget _divider(double height) {
    return Container(width: 1, height: height, color: SolrunColors.darkBorder);
  }
}
