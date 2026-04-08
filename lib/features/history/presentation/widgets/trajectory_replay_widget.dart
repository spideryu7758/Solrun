import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../data/database.dart';
import '../../../../shared/services/map_preferences.dart';
import '../../../../shared/services/tile_cache_service.dart';
import '../../../../shared/utils/coord_converter.dart';
import '../../../../shared/utils/pace_color_mapper.dart';
import '../../../../shared/utils/polyline_simplifier.dart';
import '../../../../shared/widgets/run_map.dart';

/// 轨迹回放组件
/// 渐进绘制路线 + 移动标记 + 固定总时长 + 实时数据面板
class TrajectoryReplayWidget extends StatefulWidget {
  final List<RoutePoint> points;
  final RunSession session;

  const TrajectoryReplayWidget({
    super.key,
    required this.points,
    required this.session,
  });

  @override
  State<TrajectoryReplayWidget> createState() => _TrajectoryReplayWidgetState();
}

class _TrajectoryReplayWidgetState extends State<TrajectoryReplayWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final MapController _mapController = MapController();

  /// 可选回放总时长（秒）
  static const _durationOptions = [5, 10, 20];
  int _replaySeconds = 10;

  // 预处理数据
  late final List<({LatLng point, double speed})> _simplified;
  late final double _fitZoom;
  late final LatLng _mapCenter;
  late final List<double> _cumulativeDistances;
  late final List<double> _cumulativeTimes;

  // 瓦片配置（从 MapPreferences 异步加载）
  String? _tileUrl;
  List<String> _subdomains = defaultSubdomains;
  bool _needsGcj02 = false;

  // 预计算的 GCJ-02 转换坐标（避免每帧重算）
  List<LatLng>? _convertedAllPoints;
  LatLng? _convertedCenter;

  @override
  void initState() {
    super.initState();
    _prepareData();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _replaySeconds),
    );
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
        // GCJ-02 标志加载完成后预计算转换坐标，避免每帧重算
        _precomputeConvertedCoords();
      });
    }
  }

  /// GCJ-02 坐标转换（仅用于动态插值点）
  LatLng _convert(LatLng point) =>
      _needsGcj02 ? CoordConverter.wgs84ToGcj02(point) : point;

  /// 预计算全部简化点和地图中心的 GCJ-02 坐标
  /// 在 _loadTileConfig 完成后调用一次，后续每帧直接使用缓存结果
  void _precomputeConvertedCoords() {
    final allRaw = _simplified.map((s) => s.point).toList();
    _convertedAllPoints = _needsGcj02
        ? CoordConverter.wgs84ToGcj02List(allRaw)
        : allRaw;
    _convertedCenter = _convert(_mapCenter);
  }

  void _prepareData() {
    final pts = widget.points;
    final latLngs = pts.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final speeds = pts.map((p) => p.speed).toList();
    _simplified = PolylineSimplifier.simplifyWithSpeed(latLngs, speeds, zoom: 15);
    _fitZoom = RunMap.fitZoom(latLngs);

    final centerLat = latLngs.map((p) => p.latitude).reduce((a, b) => a + b) / latLngs.length;
    final centerLng = latLngs.map((p) => p.longitude).reduce((a, b) => a + b) / latLngs.length;
    _mapCenter = LatLng(centerLat, centerLng);

    // 累计距离
    _cumulativeDistances = [0.0];
    const distCalc = Distance();
    for (int i = 1; i < _simplified.length; i++) {
      final d = distCalc.as(LengthUnit.Meter, _simplified[i - 1].point, _simplified[i].point);
      _cumulativeDistances.add(_cumulativeDistances.last + d);
    }

    // 累计时间（均匀分布近似）
    final totalSec = widget.session.durationSeconds.toDouble();
    final n = (_simplified.length - 1).clamp(1, double.maxFinite.toInt());
    _cumulativeTimes = List.generate(_simplified.length, (i) => totalSec * i / n);
  }

  void _setDuration(int seconds) {
    final progress = _controller.value;
    final wasPlaying = _controller.isAnimating;
    setState(() => _replaySeconds = seconds);
    _controller.duration = Duration(seconds: seconds);
    if (wasPlaying) {
      _controller.forward(from: progress);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.rpBg,
      appBar: AppBar(
        title: const Text('轨迹回放'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(child: _buildReplayMap()),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildReplayMap() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final totalPoints = _simplified.length;
        if (totalPoints < 2) {
          return RunMap(center: _mapCenter, zoom: _fitZoom);
        }

        // 当前进度对应的点索引
        final currentIndex = (progress * (totalPoints - 1)).floor().clamp(0, totalPoints - 2);
        final frac = progress * (totalPoints - 1) - currentIndex;

        // 当前位置插值
        final from = _simplified[currentIndex].point;
        final to = _simplified[(currentIndex + 1).clamp(0, totalPoints - 1)].point;
        final currentPos = LatLng(
          from.latitude + (to.latitude - from.latitude) * frac,
          from.longitude + (to.longitude - from.longitude) * frac,
        );

        // 已播放轨迹的速度（热力着色用）
        final playedSpeeds = <double>[
          for (int i = 0; i <= currentIndex; i++)
            _simplified[i].speed,
          _simplified[currentIndex].speed,
        ];

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final tileUrl = _tileUrl ?? (isDark ? darkTileUrl : lightTileUrl);

        // 使用预计算的转换坐标（静态点），仅对动态插值点做实时转换
        final allPoints = _convertedAllPoints
            ?? _simplified.map((s) => s.point).toList();
        final convertedPlayed = <LatLng>[
          for (int i = 0; i <= currentIndex; i++)
            allPoints[i],
          _convert(currentPos),
        ];
        final convertedCurrentPos = _convert(currentPos);
        final convertedCenter = _convertedCenter ?? _mapCenter;

        // 自动跟随（需要用转换后的坐标）
        if (_controller.isAnimating) {
          try {
            _mapController.move(convertedCurrentPos, _mapController.camera.zoom);
          } catch (_) {}
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: convertedCenter,
            initialZoom: _fitZoom,
            backgroundColor: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
          ),
          children: [
            TileLayer(
              urlTemplate: tileUrl,
              subdomains: _subdomains,
              tileProvider: CachedTileProvider(),
            ),
            // 未播放轨迹（半透明）
            if (allPoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: allPoints,
                    color: Colors.white24,
                    strokeWidth: 2.0,
                  ),
                ],
              ),
            // 已播放轨迹（热力着色）
            if (convertedPlayed.length >= 2)
              PolylineLayer(polylines: _buildHeatmapPolylines(convertedPlayed, playedSpeeds)),
            // 标记
            MarkerLayer(
              markers: [
                // 起点
                Marker(
                  point: allPoints.first,
                  width: 12, height: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF47FF47),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? SolrunColors.darkBg : SolrunColors.lightBg,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // 当前位置
                Marker(
                  point: convertedCurrentPos,
                  width: 18, height: 18,
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
                          blurRadius: 12, spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Polyline> _buildHeatmapPolylines(List<LatLng> points, List<double> speeds) {
    if (speeds.length != points.length || points.length < 2) {
      return [Polyline(points: points, color: SolrunColors.accent, strokeWidth: 3.0)];
    }
    final segmentColors = PaceColorMapper.mapSegmentColors(speeds);
    final merged = PaceColorMapper.mergeSegments(segmentColors);
    return merged.map((seg) {
      final segPoints = seg.indices.where((i) => i < points.length).map((i) => points[i]).toList();
      return Polyline(points: segPoints, color: seg.color, strokeWidth: 3.0);
    }).toList();
  }

  Widget _buildControlPanel() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final totalPoints = _simplified.length;
        final currentIndex = (progress * (totalPoints - 1)).floor().clamp(0, totalPoints - 1);

        // 当前距离和时间
        final distM = currentIndex < _cumulativeDistances.length ? _cumulativeDistances[currentIndex] : 0.0;
        final timeSec = currentIndex < _cumulativeTimes.length ? _cumulativeTimes[currentIndex] : 0.0;
        final distKm = (distM / 1000).toStringAsFixed(2);
        final timeMin = (timeSec ~/ 60).toString().padLeft(2, '0');
        final timeSc = (timeSec.toInt() % 60).toString().padLeft(2, '0');

        // 当前配速
        final speed = currentIndex < _simplified.length ? _simplified[currentIndex].speed : 0.0;
        String paceStr = '--\'--"';
        if (speed > 0.5) {
          final paceSecPerKm = (1000 / speed).round();
          paceStr = '${paceSecPerKm ~/ 60}\'${(paceSecPerKm % 60).toString().padLeft(2, '0')}"';
        }

        final isPlaying = _controller.isAnimating;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: context.rpCard,
            border: Border(top: BorderSide(color: context.rpBorder)),
          ),
          child: Column(
            children: [
              // 数据面板
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _replayMetric(distKm, 'km'),
                  _replayMetric('$timeMin:$timeSc', '用时'),
                  _replayMetric(paceStr, '配速'),
                ],
              ),
              const SizedBox(height: 12),

              // 进度条
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: SolrunColors.accent,
                  inactiveTrackColor: context.rpBorder,
                  thumbColor: SolrunColors.accent,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: progress,
                  onChanged: (v) => _controller.value = v,
                  onChangeStart: (_) { if (isPlaying) _controller.stop(); },
                ),
              ),

              // 控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 总时长选择
                  ..._durationOptions.map((sec) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _setDuration(sec),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _replaySeconds == sec ? SolrunColors.accent : context.rpBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _replaySeconds == sec ? SolrunColors.accent : context.rpBorder,
                          ),
                        ),
                        child: Text(
                          '${sec}s',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _replaySeconds == sec ? const Color(0xFF0A0A0F) : context.rpText,
                          ),
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(width: 16),

                  // 播放/暂停
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _controller.stop();
                      } else if (_controller.value >= 1.0) {
                        _controller.forward(from: 0);
                      } else {
                        _controller.forward();
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: SolrunColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: SolrunColors.accent.withValues(alpha: 0.4), blurRadius: 12),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xFF0A0A0F), size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 重置
                  GestureDetector(
                    onTap: () { _controller.reset(); setState(() {}); },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.rpBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.rpBorder),
                      ),
                      child: Icon(Icons.replay, color: context.rpText, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _replayMetric(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(
          fontFamily: 'JetBrainsMono', fontSize: 18,
          fontWeight: FontWeight.w600, color: SolrunColors.accent,
        )),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          fontSize: 10, color: context.rpMuted, letterSpacing: 1.5,
        )),
      ],
    );
  }
}
