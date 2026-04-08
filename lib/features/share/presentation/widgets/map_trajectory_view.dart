import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../shared/services/map_preferences.dart';
import '../../../../shared/services/tile_cache_service.dart';
import '../../../../shared/utils/coord_converter.dart';
import '../../../../shared/utils/pace_color_mapper.dart';
import '../../../../shared/widgets/run_map.dart';
import '../../domain/share_card_config.dart';
import '../../domain/share_card_data.dart';

/// 共享地图轨迹组件 — 在分享卡片中渲染 FlutterMap 地图瓦片 + 轨迹线 + 起终点
/// 供 4 种模板复用，启用地图底图时替代 Canvas HeatmapRoutePainter
/// 居中逻辑与详情页 RunMap 保持一致：点平均值 + fitZoom
class MapTrajectoryView extends StatefulWidget {
  final ShareCardData data;
  final ShareCardConfig config;
  final BorderRadius? borderRadius;

  const MapTrajectoryView({
    super.key,
    required this.data,
    required this.config,
    this.borderRadius,
  });

  @override
  State<MapTrajectoryView> createState() => _MapTrajectoryViewState();
}

class _MapTrajectoryViewState extends State<MapTrajectoryView> {
  String? _tileUrl;
  List<String> _subdomains = defaultSubdomains;
  bool _needsGcj02 = false;

  @override
  void initState() {
    super.initState();
    _loadTileConfig();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTileConfig();
  }

  Future<void> _loadTileConfig() async {
    final brightness = Theme.of(context).brightness;
    final url = await MapPreferences.getTileUrl(brightness);
    final subdomains = await MapPreferences.getSubdomains();
    final gcj02 = await MapPreferences.needsGcj02();
    if (mounted) {
      setState(() {
        _tileUrl = url;
        _subdomains = subdomains;
        _needsGcj02 = gcj02;
      });
    }
  }

  /// 按需转换坐标列表（高德等 GCJ-02 瓦片源）
  List<LatLng> _convertList(List<LatLng> points) =>
      _needsGcj02 ? CoordConverter.wgs84ToGcj02List(points) : points;

  @override
  Widget build(BuildContext context) {
    // 瓦片配置未加载完成前不渲染地图（与 RunMap 一致）
    // 避免 GCJ-02 状态未就绪时 initialCenter/initialZoom 被错误冻结
    if (_tileUrl == null) {
      return Container(
        color: SolrunColors.darkBg,
      );
    }

    final data = widget.data;
    final config = widget.config;

    final rawPoints =
        data.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final polylinePoints = _convertList(rawPoints);

    // 与详情页完全一致的居中逻辑
    final center = _computeCenter(polylinePoints);
    final zoom = RunMap.fitZoom(polylinePoints);

    Widget mapWidget = FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        backgroundColor: SolrunColors.darkBg,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl!,
          subdomains: _subdomains,
          tileProvider: CachedTileProvider(),
        ),
        if (polylinePoints.length >= 2)
          PolylineLayer(polylines: _buildPolylines(polylinePoints, config)),
        if (polylinePoints.length >= 2)
          MarkerLayer(
            markers: [
              Marker(
                point: polylinePoints.first,
                width: 14,
                height: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF47FF47),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SolrunColors.darkBg,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF47FF47).withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Marker(
                point: polylinePoints.last,
                width: 14,
                height: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: SolrunColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SolrunColors.darkBg,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SolrunColors.accent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    if (widget.borderRadius != null) {
      mapWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: mapWidget,
      );
    }

    return mapWidget;
  }

  /// 点平均值中心 — 与详情页 history_detail_screen 一致
  LatLng _computeCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(39.9, 116.4);
    final centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final centerLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a + b) / points.length;
    return LatLng(centerLat, centerLng);
  }

  /// 构建轨迹线：热力模式或单色
  List<Polyline> _buildPolylines(
      List<LatLng> points, ShareCardConfig config) {
    final speeds = widget.data.speeds;

    // 热力模式
    if (config.showHeatmap &&
        speeds.length == widget.data.points.length &&
        speeds.length >= 2) {
      final segmentColors = PaceColorMapper.mapSegmentColors(speeds);
      final merged = PaceColorMapper.mergeSegments(segmentColors);
      return merged.map((seg) {
        final segPoints = seg.indices.map((i) {
          if (i < points.length) return points[i];
          return points.last;
        }).toList();
        return Polyline(
          points: segPoints,
          color: seg.color,
          strokeWidth: 3.5,
        );
      }).toList();
    }

    // 单色模式
    return [
      Polyline(
        points: points,
        color: SolrunColors.accent,
        strokeWidth: 3.5,
      ),
    ];
  }
}
