import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme.dart';
import '../services/map_preferences.dart';
import '../services/tile_cache_service.dart';
import '../utils/coord_converter.dart';
import '../utils/pace_color_mapper.dart';

/// 默认瓦片源 URL
const darkTileUrl = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
const lightTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const defaultSubdomains = ['a', 'b', 'c', 'd'];

/// 通用跑步地图组件
/// 支持缓存瓦片 + 可配置瓦片源 + 离线回退
class RunMap extends StatefulWidget {
  /// 地图中心点
  final LatLng center;

  /// 轨迹点（已降采样）
  final List<LatLng> polylinePoints;

  /// 是否显示当前位置脉冲点
  final bool showCurrentLocation;

  /// 地图 zoom level
  final double zoom;

  /// 地图高度（null 则占满父容器）
  final double? height;

  /// 地图控制器（外部传入以支持跟随）
  final MapController? controller;

  /// 是否可交互（历史详情页可缩放，运动中不可）
  final bool interactive;

  /// 是否显示起终点标记
  final bool showStartEndMarkers;

  /// 每个轨迹点对应的速度 (m/s)，启用热力模式
  /// 长度必须与 polylinePoints 一致，传入则自动启用热力着色
  final List<double>? speeds;

  const RunMap({
    super.key,
    required this.center,
    this.polylinePoints = const [],
    this.showCurrentLocation = false,
    this.zoom = 16,
    this.height,
    this.controller,
    this.interactive = true,
    this.showStartEndMarkers = false,
    this.speeds,
  });

  /// 计算自适应 zoom level（使轨迹填满地图）
  static double fitZoom(List<LatLng> points, {double padding = 0.2}) {
    if (points.isEmpty) return 16;
    if (points.length == 1) return 16;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latDiff = (maxLat - minLat) * (1 + padding);
    final lngDiff = (maxLng - minLng) * (1 + padding);
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // 操场跑圈等极小范围：maxDiff 接近 0 时直接返回最大 zoom，防止除零 / NaN
    if (maxDiff < 0.00001) return 18.0;

    final zoom = (360 / maxDiff).clamp(1.0, double.infinity);
    return (zoom._log2()).clamp(3.0, 18.0);
  }

  @override
  State<RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<RunMap> {
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

  /// 按需转换坐标（高德等 GCJ-02 瓦片源）
  LatLng _convert(LatLng point) =>
      _needsGcj02 ? CoordConverter.wgs84ToGcj02(point) : point;

  List<LatLng> _convertList(List<LatLng> points) =>
      _needsGcj02 ? CoordConverter.wgs84ToGcj02List(points) : points;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 瓦片配置未加载完成前不渲染地图，避免双源叠加
    if (_tileUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: widget.height,
          color: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
        ),
      );
    }

    final tileUrl = _tileUrl!;

    // GCJ-02 坐标转换（高德等中国瓦片源需要）
    final center = _convert(widget.center);
    final polylinePoints = _convertList(widget.polylinePoints);

    Widget map = FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.zoom,
        backgroundColor: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        // 瓦片层（CachedTileProvider 提供文件缓存 + 离线回退）
        TileLayer(
          urlTemplate: tileUrl,
          subdomains: _subdomains,
          tileProvider: CachedTileProvider(),
        ),
        // 轨迹线（热力模式或单色模式）
        if (polylinePoints.length >= 2)
          PolylineLayer(polylines: _buildPolylines(polylinePoints)),
        // 起终点标记
        if (widget.showStartEndMarkers && polylinePoints.length >= 2)
          MarkerLayer(
            markers: [
              // 起点（绿色）
              Marker(
                point: polylinePoints.first,
                width: 14,
                height: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF47FF47),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
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
              // 终点（accent 黄）
              Marker(
                point: polylinePoints.last,
                width: 14,
                height: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: SolrunColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
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
        // 当前位置点
        if (widget.showCurrentLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: SolrunColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SolrunColors.accent.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    if (widget.height != null) {
      map = SizedBox(height: widget.height, child: map);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: map,
    );
  }

  /// 构建轨迹线：有速度数据时用热力着色，否则单色
  List<Polyline> _buildPolylines(List<LatLng> points) {
    final speeds = widget.speeds;

    // 无速度数据或长度不匹配：单色模式
    if (speeds == null || speeds.length != points.length) {
      return [
        Polyline(
          points: points,
          color: SolrunColors.accent,
          strokeWidth: 3.0,
        ),
      ];
    }

    // 速度数据不足以生成热力分段时，回退到单色模式
    if (speeds.length < 2) {
      return [
        Polyline(
          points: points,
          color: SolrunColors.accent,
          strokeWidth: 3.0,
        ),
      ];
    }

    // 热力模式：按配速着色
    final segmentColors = PaceColorMapper.mapSegmentColors(speeds);
    final merged = PaceColorMapper.mergeSegments(segmentColors);

    return merged.map((seg) {
      final segPoints = seg.indices.map((i) => points[i]).toList();
      return Polyline(
        points: segPoints,
        color: seg.color,
        strokeWidth: 3.0,
      );
    }).toList();
  }
}

extension on double {
  double _log2() => log(this) / ln2;
}
