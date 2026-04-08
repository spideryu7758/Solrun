import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 地图瓦片源预设
enum TileSource {
  /// 自动（深色→CartoDB Dark，浅色→OSM）
  auto('自动', '跟随主题自动切换'),

  /// OpenStreetMap 标准
  osm('OpenStreetMap', '开源地图，全球覆盖'),

  /// CartoDB Dark Matter
  cartoDark('CartoDB Dark', '深色底图，夜跑推荐'),

  /// CartoDB Voyager（浅色精美）
  cartoVoyager('CartoDB Voyager', '浅色精美底图'),

  /// CyclOSM（自行车/户外）
  cyclosm('CyclOSM', '户外地形图，越野推荐'),

  /// 高德地图（中国大陆推荐）
  amap('高德地图', '中国大陆推荐，速度快'),

  /// 用户自定义 URL
  custom('自定义', '输入自定义瓦片 URL');

  final String label;
  final String description;
  const TileSource(this.label, this.description);

  /// 获取瓦片 URL 模板
  String? get urlTemplate => switch (this) {
    TileSource.osm => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    TileSource.cartoDark => 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    TileSource.cartoVoyager => 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    TileSource.cyclosm => 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
    TileSource.amap => 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
    TileSource.auto => null,
    TileSource.custom => null,
  };

  /// 是否需要子域名
  List<String> get subdomains => switch (this) {
    TileSource.cartoDark || TileSource.cartoVoyager || TileSource.cyclosm
        => const ['a', 'b', 'c', 'd'],
    TileSource.amap => const ['1', '2', '3', '4'],
    _ => const [],
  };

  /// 是否需要 GCJ-02 坐标转换（高德/腾讯使用火星坐标系）
  bool get needsGcj02 => this == TileSource.amap;
}

/// 地图偏好设置存储
class MapPreferences {
  static const _keyTileSource = 'map_tile_source';
  static const _keyCustomUrl = 'map_custom_tile_url';
  static const _keyAmapApiKey = 'amap_api_key';
  static const _secureStorage = FlutterSecureStorage();

  /// 读取当前瓦片源
  static Future<TileSource> getTileSource() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyTileSource);
    if (name == null) return TileSource.auto;
    return TileSource.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TileSource.auto,
    );
  }

  /// 保存瓦片源
  static Future<void> setTileSource(TileSource source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTileSource, source.name);
  }

  /// 读取自定义瓦片 URL
  static Future<String> getCustomUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomUrl) ?? '';
  }

  /// 保存自定义瓦片 URL
  static Future<void> setCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomUrl, url);
  }

  /// 根据当前设置和主题亮度获取实际瓦片 URL
  static Future<String> getTileUrl(Brightness brightness) async {
    final source = await getTileSource();

    if (source == TileSource.auto) {
      return brightness == Brightness.dark
          ? TileSource.cartoDark.urlTemplate!
          : TileSource.osm.urlTemplate!;
    }

    if (source == TileSource.custom) {
      final url = await getCustomUrl();
      return url.isNotEmpty ? url : TileSource.osm.urlTemplate!;
    }

    return source.urlTemplate!;
  }

  /// 获取当前瓦片源的子域名
  static Future<List<String>> getSubdomains() async {
    final source = await getTileSource();
    if (source == TileSource.auto) {
      return const ['a', 'b', 'c', 'd'];
    }
    return source.subdomains;
  }

  /// 当前瓦片源是否需要 GCJ-02 坐标转换
  static Future<bool> needsGcj02() async {
    final source = await getTileSource();
    return source.needsGcj02;
  }

  /// 读取高德 API Key（加密存储）
  static Future<String> getAmapApiKey() async {
    return await _secureStorage.read(key: _keyAmapApiKey) ?? '';
  }

  /// 保存高德 API Key（加密存储）
  static Future<void> setAmapApiKey(String key) async {
    if (key.isEmpty) {
      await _secureStorage.delete(key: _keyAmapApiKey);
    } else {
      await _secureStorage.write(key: _keyAmapApiKey, value: key);
    }
  }
}
