import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../data/database.dart';
import '../../features/tracking/domain/elevation_calculator.dart';

/// 在线地形高程服务。
///
/// 使用 Open-Meteo Elevation API（Copernicus DEM GLO-90，90m 分辨率）。
/// API 支持一次最多 100 个 WGS-84 坐标点；商业保留资源才需要 apikey。
/// 获取失败时返回 null，调用方应回退到 GPS 海拔估算。
class ElevationService {
  ElevationService._();

  static const _endpoint = 'https://api.open-meteo.com/v1/elevation';
  static const _batchSize = 100;
  static const _maxPoints = 200;

  /// 根据轨迹经纬度查询 DEM 地面海拔并计算累计爬升。
  static Future<double?> fetchElevationGain(List<RoutePoint> points) async {
    try {
      return await _fetchElevationGain(
        points,
      ).timeout(const Duration(seconds: 12));
    } catch (_) {
      return null;
    }
  }

  static Future<double?> _fetchElevationGain(List<RoutePoint> points) async {
    if (points.length < 2) return null;

    final sampled = _samplePoints(points);
    if (sampled.length < 2) return null;

    final elevations = <double>[];
    for (var start = 0; start < sampled.length; start += _batchSize) {
      final end = min(start + _batchSize, sampled.length);
      final batch = sampled.sublist(start, end);
      final batchElevations = await _fetchBatch(batch);
      if (batchElevations == null) return null;
      elevations.addAll(batchElevations);
    }

    if (elevations.length < 2) return null;
    return ElevationCalculator.calculateGain(elevations);
  }

  static List<RoutePoint> _samplePoints(List<RoutePoint> points) {
    if (points.length <= _maxPoints) return points;

    final step = points.length / _maxPoints;
    final sampled = <RoutePoint>[];
    for (var i = 0; i < _maxPoints; i++) {
      sampled.add(points[(i * step).floor().clamp(0, points.length - 1)]);
    }
    if (sampled.last != points.last) sampled.add(points.last);
    return sampled;
  }

  static Future<List<double>?> _fetchBatch(List<RoutePoint> points) async {
    final latitudes = points
        .map((p) => p.latitude.toStringAsFixed(6))
        .join(',');
    final longitudes = points
        .map((p) => p.longitude.toStringAsFixed(6))
        .join(',');
    final url = Uri.parse(
      '$_endpoint?latitude=$latitudes&longitude=$longitudes',
    );

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
      final request = await client.getUrl(url);
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200) return null;

      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 8));
      final json = jsonDecode(body) as Map<String, dynamic>;
      final values = json['elevation'] as List<dynamic>?;
      if (values == null || values.length != points.length) return null;

      return values.map((value) => (value as num).toDouble()).toList();
    } catch (_) {
      return null;
    } finally {
      client?.close();
    }
  }
}
