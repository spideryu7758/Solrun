import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/map_preferences.dart';
import '../../../../shared/services/tile_cache_service.dart';
import '../../../../shared/widgets/rp_components.dart';

/// 地图设置区域：瓦片源 + 高德 API Key + 自定义 URL + 缓存管理
class MapSettingsSection extends ConsumerStatefulWidget {
  const MapSettingsSection({super.key});

  @override
  ConsumerState<MapSettingsSection> createState() =>
      _MapSettingsSectionState();
}

class _MapSettingsSectionState extends ConsumerState<MapSettingsSection> {
  TileSource _tileSource = TileSource.auto;
  String _customTileUrl = '';
  String _amapApiKey = '';
  int _tileCacheSizeMb = 0;

  @override
  void initState() {
    super.initState();
    _loadMapPrefs();
  }

  Future<void> _loadMapPrefs() async {
    final source = await MapPreferences.getTileSource();
    final customUrl = await MapPreferences.getCustomUrl();
    final amapKey = await MapPreferences.getAmapApiKey();
    final cacheBytes = await CachedTileProvider.getCacheSize();
    if (mounted) {
      setState(() {
        _tileSource = source;
        _customTileUrl = customUrl;
        _amapApiKey = amapKey;
        _tileCacheSizeMb = (cacheBytes / 1024 / 1024).round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RpSectionHeader(S.of(context)!.settings_mapSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildTileSourceTile(),
              if (_tileSource == TileSource.amap) _buildAmapApiKeyTile(),
              if (_tileSource == TileSource.custom)
                _buildCustomTileUrlTile(),
              _buildActionTile(
                S.of(context)!.settings_mapCache,
                '$_tileCacheSizeMb MB',
                Icons.cached,
                _clearTileCache,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // --------------- 瓦片源选择 ---------------

  Widget _buildTileSourceTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_mapSource),
      subtitle: Text(_tileSource.description,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      trailing: DropdownButton<TileSource>(
        value: _tileSource,
        dropdownColor: context.rpCard,
        items: TileSource.values
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label,
                      style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _tileSource = v);
            MapPreferences.setTileSource(v);
          }
        },
      ),
    );
  }

  // --------------- 高德 API Key ---------------

  Widget _buildAmapApiKeyTile() {
    final hasKey = _amapApiKey.isNotEmpty;
    return ListTile(
      title: Text(S.of(context)!.settings_amapApiKey),
      subtitle: Text(
        hasKey
            ? '已配置 (${_amapApiKey.substring(0, 4)}****)'
            : S.of(context)!.settings_amapApiKeyHint,
        style: TextStyle(fontSize: 12, color: context.rpMuted),
      ),
      trailing: const Icon(Icons.vpn_key, size: 18),
      onTap: () async {
        final controller = TextEditingController(text: _amapApiKey);
        try {
          final result = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: context.rpCard,
              title: Text(S.of(context)!.settings_amapApiKey,
                  style: TextStyle(color: context.rpText)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context)!.settings_amapApiKeyDesc,
                    style: TextStyle(
                        fontSize: 12, color: context.rpMuted),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: S.of(context)!
                          .settings_amapApiKeyPlaceholder,
                      hintStyle: const TextStyle(fontSize: 12),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(S.of(context)!.settings_cancel,
                      style: TextStyle(color: context.rpMuted)),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: Text(S.of(context)!.settings_confirm,
                      style: TextStyle(color: context.rpAccent)),
                ),
              ],
            ),
          );
          if (result != null) {
            setState(() => _amapApiKey = result);
            MapPreferences.setAmapApiKey(result);
          }
        } finally {
          controller.dispose();
        }
      },
    );
  }

  // --------------- 自定义瓦片 URL ---------------

  Widget _buildCustomTileUrlTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_customTileUrl),
      subtitle: Text(
        _customTileUrl.isEmpty
            ? S.of(context)!.settings_customTileUrlHint
            : _customTileUrl,
        style: TextStyle(fontSize: 11, color: context.rpMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: () async {
        final controller =
            TextEditingController(text: _customTileUrl);
        try {
          final result = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: context.rpCard,
              title: Text(S.of(context)!.settings_customTileUrl,
                  style: TextStyle(color: context.rpText)),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText:
                      'https://tile.example.com/{z}/{x}/{y}.png',
                  hintStyle: TextStyle(fontSize: 12),
                ),
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(S.of(context)!.settings_cancel,
                      style: TextStyle(color: context.rpMuted)),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: Text(S.of(context)!.settings_confirm,
                      style: TextStyle(color: context.rpAccent)),
                ),
              ],
            ),
          );
          if (result != null) {
            setState(() => _customTileUrl = result);
            MapPreferences.setCustomUrl(result);
          }
        } finally {
          controller.dispose();
        }
      },
    );
  }

  // --------------- 缓存清理 ---------------

  Future<void> _clearTileCache() async {
    final confirmed = await RpDialog.confirm(
      context,
      title: S.of(context)!.settings_clearMapCacheTitle,
      content:
          S.of(context)!.settings_clearMapCacheContent(_tileCacheSizeMb),
      confirmText: S.of(context)!.settings_clear,
      confirmColor: context.rpDanger,
    );

    if (confirmed) {
      await CachedTileProvider.clearCache();
      await _loadMapPrefs();
      if (mounted) {
        RpSnackBar.show(
            context, S.of(context)!.settings_mapCacheCleared);
      }
    }
  }

  // --------------- 通用 ---------------

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.rpText),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      onTap: onTap,
    );
  }
}
