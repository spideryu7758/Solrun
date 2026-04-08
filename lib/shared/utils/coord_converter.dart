import 'dart:math';

import 'package:latlong2/latlong.dart';

/// WGS-84 ↔ GCJ-02 坐标转换
/// 高德/腾讯地图使用 GCJ-02（"火星坐标系"），GPS 原始数据为 WGS-84。
/// 仅在渲染层转换，数据库始终存储 WGS-84 原始坐标。
class CoordConverter {
  static const double _a = 6378245.0; // 长半轴
  static const double _ee = 0.00669342162296594323; // 扁率

  /// 判断坐标是否在中国境内（粗略矩形判定）
  ///
  /// 边界值来源：中国领土大致经纬度范围
  /// - 纬度 3.86°N（南沙群岛曾母暗沙）~ 53.55°N（漠河）
  /// - 经度 73.66°E（帕米尔高原）~ 135.05°E（乌苏里江黑瞎子岛）
  /// 此矩形仅用于 GCJ-02 偏移判定，非严格国境线；
  /// 边界附近少量境外点误判不影响地图渲染效果。
  static bool _inChina(double lat, double lng) {
    return lat >= 3.86 && lat <= 53.55 && lng >= 73.66 && lng <= 135.05;
  }

  /// WGS-84 → GCJ-02
  static LatLng wgs84ToGcj02(LatLng wgs) {
    if (!_inChina(wgs.latitude, wgs.longitude)) return wgs;

    final dLat = _transformLat(wgs.longitude - 105.0, wgs.latitude - 35.0);
    final dLng = _transformLng(wgs.longitude - 105.0, wgs.latitude - 35.0);
    final radLat = wgs.latitude / 180.0 * pi;
    var magic = sin(radLat);
    magic = 1 - _ee * magic * magic;
    final sqrtMagic = sqrt(magic);

    final adjustedDLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * pi);
    final adjustedDLng = (dLng * 180.0) / (_a / sqrtMagic * cos(radLat) * pi);

    return LatLng(wgs.latitude + adjustedDLat, wgs.longitude + adjustedDLng);
  }

  /// 批量转换（轨迹点列表）
  static List<LatLng> wgs84ToGcj02List(List<LatLng> points) {
    return points.map(wgs84ToGcj02).toList();
  }

  static double _transformLat(double x, double y) {
    var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y +
        0.1 * x * y + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLng(double x, double y) {
    var ret = 300.0 + x + 2.0 * y + 0.1 * x * x +
        0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
  }
}
