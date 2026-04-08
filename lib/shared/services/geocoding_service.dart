import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'map_preferences.dart';

/// 反向地理编码服务（高德优先 → Nominatim 兜底）
///
/// 根据 GPS 经纬度获取城市名称。
/// 跑步结束时调用一次，写入 RunSession 记录。
class GeocodingService {
  GeocodingService._();

  static String? _cachedCity;
  static DateTime? _cachedAt;
  static double? _cachedLat;
  static double? _cachedLon;

  /// 获取城市名（缓存 10 分钟，同一坐标附近不重复请求）
  static Future<String?> getCity(
    double lat,
    double lon, {
    String lang = 'zh',
  }) async {
    // 10 分钟内、坐标偏差 <0.01°（约 1km）复用缓存
    if (_cachedCity != null &&
        _cachedAt != null &&
        _cachedLat != null &&
        _cachedLon != null &&
        DateTime.now().difference(_cachedAt!).inMinutes < 10 &&
        (lat - _cachedLat!).abs() < 0.01 &&
        (lon - _cachedLon!).abs() < 0.01) {
      return _cachedCity;
    }

    try {
      // 有高德 Key 时优先走高德（国内更稳定）
      final amapKey = await MapPreferences.getAmapApiKey();
      String? city;
      if (amapKey.isNotEmpty) {
        city = await _fetchCityAmap(lat, lon, amapKey);
      }
      // 高德失败或无 Key，fallback Nominatim（强制 IPv4）
      city ??= await _fetchCityNominatim(lat, lon, lang: lang);

      if (city != null && city.isNotEmpty) {
        _cachedCity = city;
        _cachedAt = DateTime.now();
        _cachedLat = lat;
        _cachedLon = lon;
      }
      return city;
    } catch (e) {
      debugPrint('[GeocodingService] 城市识别失败: $e');
      return null;
    }
  }

  /// 高德反向地理编码（国内稳定，需 Web 服务 API Key）
  static Future<String?> _fetchCityAmap(
    double lat,
    double lon,
    String apiKey,
  ) async {
    // 高德 API 坐标格式：经度,纬度（注意顺序）
    final url = Uri.parse(
      'https://restapi.amap.com/v3/geocode/regeo'
      '?location=${lon.toStringAsFixed(6)},${lat.toStringAsFixed(6)}'
      '&key=$apiKey'
      '&radius=1000'
      '&extensions=base',
    );

    debugPrint('[GeocodingService] 高德请求: $url');
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(url);
      final response = await request.close().timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['status'] != '1') {
        debugPrint('[GeocodingService] 高德返回错误: ${json['info']}');
        return null;
      }

      final regeocode = json['regeocode'] as Map<String, dynamic>?;
      final addressComponent =
          regeocode?['addressComponent'] as Map<String, dynamic>?;
      if (addressComponent == null) return null;

      // 优先取 city，高德在直辖市下 city 为空数组，此时用 province
      final city = addressComponent['city'];
      final province = addressComponent['province'] as String?;
      String? result;
      if (city is String && city.isNotEmpty) {
        result = city;
      } else if (province != null && province.isNotEmpty) {
        result = province;
      }

      debugPrint('[GeocodingService] 高德解析城市: $result');
      return result;
    } catch (e) {
      debugPrint('[GeocodingService] 高德请求失败: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Nominatim 反向地理编码（免费无 Key，强制 IPv4）
  static Future<String?> _fetchCityNominatim(
    double lat,
    double lon, {
    String lang = 'zh',
  }) async {
    const host = 'nominatim.openstreetmap.org';
    final url = Uri.parse(
      'https://$host/reverse'
      '?lat=$lat&lon=$lon'
      '&format=json'
      '&accept-language=$lang'
      '&zoom=10',
    );

    debugPrint('[GeocodingService] Nominatim 请求: $url');

    // 强制 IPv4 DNS 解析，避免 IPv6 不可达（荣耀等国产 ROM 常见）
    InternetAddress? ipv4;
    try {
      final addrs = await InternetAddress.lookup(
        host,
        type: InternetAddressType.IPv4,
      );
      if (addrs.isNotEmpty) ipv4 = addrs.first;
    } catch (e) {
      debugPrint('[GeocodingService] IPv4 DNS 解析失败: $e');
    }

    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 10);
      // 通过 connectionFactory 强制走 IPv4 地址
      // TLS 层仍使用 URL 中的 hostname 做 SNI 和证书校验
      if (ipv4 != null) {
        client.connectionFactory = (uri, proxyHost, proxyPort) async {
          return Socket.startConnect(ipv4!, uri.port);
        };
      }

      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'Solrun/1.0');
      final response = await request.close().timeout(
            const Duration(seconds: 10),
          );

      debugPrint('[GeocodingService] Nominatim 状态码: ${response.statusCode}');
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();

      final json = jsonDecode(body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>?;
      if (address == null) {
        debugPrint('[GeocodingService] 响应无 address 字段');
        return null;
      }

      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['county'] as String? ??
          address['state'] as String?;
      debugPrint('[GeocodingService] Nominatim 解析城市: $city');
      return city;
    } catch (e) {
      debugPrint('[GeocodingService] Nominatim 请求失败: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 清除缓存
  static void clearCache() {
    _cachedCity = null;
    _cachedAt = null;
    _cachedLat = null;
    _cachedLon = null;
  }
}
