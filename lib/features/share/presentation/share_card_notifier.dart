import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/share_card_config.dart';

/// 分享卡片配置状态管理
class ShareCardNotifier extends Notifier<ShareCardConfig> {
  static const _keyTemplate = 'share_template';
  static const _keyRatio = 'share_ratio';
  static const _keyHeatmap = 'share_show_heatmap';
  static const _keyMapTiles = 'share_show_map_tiles';
  static const _keyPaceChart = 'share_show_pace_chart';
  static const _keyElevationProfile = 'share_show_elevation_profile';
  static const _keyDataGrid = 'share_show_data_grid';
  static const _keyHeader = 'share_show_header';
  static const _keyWatermark = 'share_show_watermark';
  static const _keyDataEntertainment = 'share_data_entertainment';
  int _revision = 0;

  @override
  ShareCardConfig build() {
    _loadSaved();
    return const ShareCardConfig();
  }

  /// 从 SharedPreferences 恢复上次配置
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final templateIndex = prefs.getInt(_keyTemplate);
    final ratioIndex = prefs.getInt(_keyRatio);
    final hasSavedConfig =
        templateIndex != null ||
        ratioIndex != null ||
        prefs.getBool(_keyHeatmap) != null ||
        prefs.getBool(_keyMapTiles) != null ||
        prefs.getBool(_keyPaceChart) != null ||
        prefs.getBool(_keyElevationProfile) != null ||
        prefs.getBool(_keyDataGrid) != null ||
        prefs.getBool(_keyHeader) != null ||
        prefs.getBool(_keyWatermark) != null ||
        prefs.getBool(_keyDataEntertainment) != null;

    if (hasSavedConfig) {
      final template = _enumValueOrDefault(
        CardTemplate.values,
        templateIndex,
        CardTemplate.classic,
      );
      final ratio = _enumValueOrDefault(
        CardAspectRatio.values,
        ratioIndex,
        CardAspectRatio.story,
      );
      final defaults = ShareCardConfig.defaultFor(template);

      // 以模板默认配置为基础，覆盖比例，并清退当前模板/比例不支持的选项。
      final normalized = _enforceSupportedOptions(
        defaults.copyWith(
          aspectRatio: ratio,
          showHeatmap: prefs.getBool(_keyHeatmap) ?? defaults.showHeatmap,
          showMapTiles: prefs.getBool(_keyMapTiles) ?? defaults.showMapTiles,
          showPaceChart: prefs.getBool(_keyPaceChart) ?? defaults.showPaceChart,
          showElevationProfile:
              prefs.getBool(_keyElevationProfile) ??
              defaults.showElevationProfile,
          showDataGrid: prefs.getBool(_keyDataGrid) ?? defaults.showDataGrid,
          showHeader: prefs.getBool(_keyHeader) ?? defaults.showHeader,
          showWatermark: prefs.getBool(_keyWatermark) ?? defaults.showWatermark,
          showDataEntertainment:
              prefs.getBool(_keyDataEntertainment) ??
              defaults.showDataEntertainment,
        ),
      );
      state = normalized;
      final loadRevision = _revision;
      await _repairSavedIfNeeded(
        prefs: prefs,
        rawTemplateIndex: templateIndex,
        rawRatioIndex: ratioIndex,
        normalized: normalized,
        revision: loadRevision,
      );
    }
  }

  /// 持久化当前选择
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await _writeConfig(prefs, state);
  }

  void setTemplate(CardTemplate template) {
    // 切换模板时重置为该模板默认开关，保留当前比例
    _revision++;
    state = _enforceSupportedOptions(
      ShareCardConfig.defaultFor(template).copyWith(
        aspectRatio: state.aspectRatio,
        showDataEntertainment: state.showDataEntertainment,
      ),
    );
    _persist();
  }

  void setAspectRatio(CardAspectRatio ratio) {
    _revision++;
    state = _enforceSupportedOptions(state.copyWith(aspectRatio: ratio));
    _persist();
  }

  void toggleHeatmap() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showHeatmap: !state.showHeatmap),
    );
    _persist();
  }

  void toggleMapTiles() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showMapTiles: !state.showMapTiles),
    );
    _persist();
  }

  void togglePaceChart() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showPaceChart: !state.showPaceChart),
    );
    _persist();
  }

  void toggleElevationProfile() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showElevationProfile: !state.showElevationProfile),
    );
    _persist();
  }

  void toggleDataGrid() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showDataGrid: !state.showDataGrid),
    );
    _persist();
  }

  void toggleHeader() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showHeader: !state.showHeader),
    );
    _persist();
  }

  void toggleWatermark() {
    _revision++;
    state = state.copyWith(showWatermark: !state.showWatermark);
    _persist();
  }

  void toggleDataEntertainment() {
    _revision++;
    state = _enforceSupportedOptions(
      state.copyWith(showDataEntertainment: !state.showDataEntertainment),
    );
    _persist();
  }

  T _enumValueOrDefault<T>(List<T> values, int? index, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  Future<void> _repairSavedIfNeeded({
    required SharedPreferences prefs,
    required int? rawTemplateIndex,
    required int? rawRatioIndex,
    required ShareCardConfig normalized,
    required int revision,
  }) async {
    if (revision != _revision || state != normalized) return;
    if (rawTemplateIndex != normalized.template.index ||
        rawRatioIndex != normalized.aspectRatio.index ||
        prefs.getBool(_keyHeatmap) != normalized.showHeatmap ||
        prefs.getBool(_keyMapTiles) != normalized.showMapTiles ||
        prefs.getBool(_keyPaceChart) != normalized.showPaceChart ||
        prefs.getBool(_keyElevationProfile) !=
            normalized.showElevationProfile ||
        prefs.getBool(_keyDataGrid) != normalized.showDataGrid ||
        prefs.getBool(_keyHeader) != normalized.showHeader ||
        prefs.getBool(_keyWatermark) != normalized.showWatermark ||
        prefs.getBool(_keyDataEntertainment) !=
            normalized.showDataEntertainment) {
      await _writeConfig(prefs, normalized);
    }
  }

  Future<void> _writeConfig(
    SharedPreferences prefs,
    ShareCardConfig config,
  ) async {
    await prefs.setInt(_keyTemplate, config.template.index);
    await prefs.setInt(_keyRatio, config.aspectRatio.index);
    await prefs.setBool(_keyHeatmap, config.showHeatmap);
    await prefs.setBool(_keyMapTiles, config.showMapTiles);
    await prefs.setBool(_keyPaceChart, config.showPaceChart);
    await prefs.setBool(_keyElevationProfile, config.showElevationProfile);
    await prefs.setBool(_keyDataGrid, config.showDataGrid);
    await prefs.setBool(_keyHeader, config.showHeader);
    await prefs.setBool(_keyWatermark, config.showWatermark);
    await prefs.setBool(_keyDataEntertainment, config.showDataEntertainment);
  }

  ShareCardConfig _enforceSupportedOptions(ShareCardConfig config) {
    bool supported(ShareOption option) => ShareCardConfig.isOptionSupported(
      config.template,
      option,
      aspectRatio: config.aspectRatio,
    );

    return config.copyWith(
      showMapTiles: supported(ShareOption.mapTiles)
          ? config.showMapTiles
          : false,
      showPaceChart: supported(ShareOption.paceChart)
          ? config.showPaceChart
          : false,
      showElevationProfile: supported(ShareOption.elevationProfile)
          ? config.showElevationProfile
          : false,
      showDataGrid: supported(ShareOption.dataGrid)
          ? config.showDataGrid
          : false,
      showHeader: supported(ShareOption.header) ? config.showHeader : false,
      showDataEntertainment: supported(ShareOption.dataEntertainment)
          ? config.showDataEntertainment
          : false,
    );
  }

  /// 设置观众喊话水印（传 null 清除）
  void setShout(String? text, String? role) {
    if (text == null) {
      state = state.copyWith(clearShout: true);
    } else {
      state = state.copyWith(shoutText: text, shoutRole: role);
    }
  }
}
