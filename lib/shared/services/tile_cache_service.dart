import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// 瓦片缓存 TileProvider
/// 文件缓存 + LRU 淘汰 + 离线回退
class CachedTileProvider extends TileProvider {
  /// 缓存上限（字节），默认 200MB
  final int maxCacheBytes;

  /// 缓存过期时间，默认 30 天
  final Duration maxAge;

  /// 瓦片源标识（用于缓存隔离，避免不同源瓦片互相覆盖）
  final String sourceId;

  static Directory? _cacheDir;
  static bool _evicting = false;

  CachedTileProvider({
    super.headers,
    this.maxCacheBytes = 200 * 1024 * 1024,
    this.maxAge = const Duration(days: 30),
    this.sourceId = 'default',
  });

  /// 获取缓存根目录
  static Future<Directory> getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDir = await getApplicationSupportDirectory();
    _cacheDir = Directory('${appDir.path}/tiles');
    return _cacheDir!;
  }

  /// 瓦片文件路径：tiles/{sourceId}/{z}/{x}/{y}.png
  static Future<File> _tileFile(String sourceId, int z, int x, int y) async {
    final dir = await getCacheDir();
    return File('${dir.path}/$sourceId/$z/$x/$y.png');
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    // 用 urlTemplate 的 hash 作为缓存隔离键，自动区分不同瓦片源
    final effectiveSourceId = sourceId != 'default'
        ? sourceId
        : options.urlTemplate.hashCode.toRadixString(36);
    return _CachedTileImageProvider(
      url: url,
      headers: headers,
      sourceId: effectiveSourceId,
      z: coordinates.z,
      x: coordinates.x,
      y: coordinates.y,
      maxAge: maxAge,
      onTileCached: () => _maybeEvict(),
    );
  }

  /// 触发 LRU 淘汰（异步，不阻塞 UI）
  void _maybeEvict() {
    if (_evicting) return;
    _evicting = true;
    _evictIfNeeded().whenComplete(() => _evicting = false);
  }

  Future<void> _evictIfNeeded() async {
    try {
      final dir = await getCacheDir();
      if (!await dir.exists()) return;

      final files = <File>[];
      int totalSize = 0;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.png')) {
          files.add(entity);
          totalSize += await entity.length();
        }
      }

      if (totalSize <= maxCacheBytes) return;

      // 按最后访问时间排序（旧的先删）
      final stats = <File, FileStat>{};
      for (final f in files) {
        stats[f] = await f.stat();
      }
      files.sort((a, b) =>
          stats[a]!.accessed.compareTo(stats[b]!.accessed));

      // 删到上限 80% 以下
      final target = (maxCacheBytes * 0.8).toInt();
      for (final f in files) {
        if (totalSize <= target) break;
        final size = await f.length();
        await f.delete();
        totalSize -= size;
      }
    } catch (_) {
      // 淘汰失败不影响正常使用
    }
  }

  /// 获取缓存大小（字节）
  static Future<int> getCacheSize() async {
    try {
      final dir = await getCacheDir();
      if (!await dir.exists()) return 0;
      int total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// 清空缓存
  static Future<void> clearCache() async {
    try {
      final dir = await getCacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _cacheDir = null;
    } catch (_) {}
  }

  /// 预缓存指定区域的瓦片（跑步完成后调用）
  ///
  /// 并发下载，最大并发数 [maxConcurrency] 默认 6。
  static Future<void> preCacheArea({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    required String tileUrlTemplate,
    String sourceId = 'default',
    List<int> zoomLevels = const [14, 15, 16],
    Map<String, String>? headers,
    int maxConcurrency = 6,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      // 收集所有待下载瓦片的参数
      final tasks = <({int z, int x, int y, String url})>[];

      for (final z in zoomLevels) {
        final minX = _lngToTileX(minLng, z);
        final maxX = _lngToTileX(maxLng, z);
        final minY = _latToTileY(maxLat, z); // 纬度和 Y 轴反向
        final maxY = _latToTileY(minLat, z);

        // 限制单次预缓存瓦片数量
        final tileCount = (maxX - minX + 1) * (maxY - minY + 1);
        if (tileCount > 200) continue;

        for (int x = minX; x <= maxX; x++) {
          for (int y = minY; y <= maxY; y++) {
            final url = tileUrlTemplate
                .replaceAll('{z}', '$z')
                .replaceAll('{x}', '$x')
                .replaceAll('{y}', '$y')
                .replaceAll('{s}', 'a');
            tasks.add((z: z, x: x, y: y, url: url));
          }
        }
      }

      // 并发下载，通过分批 Future.wait 限制并发数
      for (int i = 0; i < tasks.length; i += maxConcurrency) {
        final batch = tasks.skip(i).take(maxConcurrency);
        await Future.wait(
          batch.map((t) => _downloadSingleTile(client, t.z, t.x, t.y, t.url,
              sourceId, headers)),
        );
      }
    } finally {
      client.close();
    }
  }

  /// 下载单个瓦片并写入缓存
  static Future<void> _downloadSingleTile(
    HttpClient client,
    int z,
    int x,
    int y,
    String url,
    String sourceId,
    Map<String, String>? headers,
  ) async {
    try {
      final file = await _tileFile(sourceId, z, x, y);
      if (await file.exists()) return;

      final request = await client.getUrl(Uri.parse(url));
      headers?.forEach((k, v) => request.headers.add(k, v));
      final response = await request.close();
      if (response.statusCode == 200) {
        await file.parent.create(recursive: true);
        final bytes = await consolidateHttpClientResponseBytes(response);
        await file.writeAsBytes(bytes);
      } else {
        await response.drain<void>();
      }
    } catch (_) {
      // 单个瓦片下载失败不影响其他瓦片
    }
  }

  /// 经度转瓦片 X 坐标
  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180) / 360 * (1 << zoom)).floor();
  }

  /// 纬度转瓦片 Y 坐标
  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    final n = 1 << zoom;
    return ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 * n).floor();
  }
}

/// 自定义 ImageProvider：优先读文件缓存，miss 则网络加载并缓存
class _CachedTileImageProvider extends ImageProvider<_CachedTileImageProvider> {
  final String url;
  final Map<String, String> headers;
  final String sourceId;
  final int z, x, y;
  final Duration maxAge;
  final VoidCallback? onTileCached;

  const _CachedTileImageProvider({
    required this.url,
    required this.headers,
    required this.sourceId,
    required this.z,
    required this.x,
    required this.y,
    required this.maxAge,
    this.onTileCached,
  });

  @override
  ImageStreamCompleter loadImage(
    _CachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadTile(decode),
      scale: 1,
      informationCollector: () => [
        DiagnosticsProperty<_CachedTileImageProvider>('Tile', this),
      ],
    );
  }

  Future<ui.Codec> _loadTile(ImageDecoderCallback decode) async {
    final file = await CachedTileProvider._tileFile(sourceId, z, x, y);
    if (await file.exists()) {
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age < maxAge) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
        }
      }
    }

    // 2. 网络加载
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(url));
      headers.forEach((k, v) => request.headers.add(k, v));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        // 写入缓存（异步，不阻塞解码）
        _writeCacheAsync(file, bytes);
        return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
      } else {
        await response.drain<void>();
      }
    } catch (_) {
      // 网络失败，尝试返回过期缓存
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
        }
      }
    }

    // 3. 完全无数据：返回 1x1 透明像素
    return decode(await ui.ImmutableBuffer.fromUint8List(_transparentPng));
  }

  void _writeCacheAsync(File file, Uint8List bytes) {
    file.parent.create(recursive: true).then((_) {
      return file.writeAsBytes(bytes);
    }).then((_) {
      onTileCached?.call();
    }).catchError((e) {
      debugPrint('[TileCache] 瓦片缓存写入失败: $e');
    });
  }

  @override
  Future<_CachedTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CachedTileImageProvider>(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _CachedTileImageProvider && url == other.url);

  @override
  int get hashCode => url.hashCode;
}

/// 1x1 透明 PNG — 瓦片加载全部失败时的最终回退
final Uint8List _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);
