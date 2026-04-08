import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/share_card_config.dart';

/// 分享卡片配置状态管理
class ShareCardNotifier extends Notifier<ShareCardConfig> {
  static const _keyTemplate = 'share_template';
  static const _keyRatio = 'share_ratio';

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

    if (templateIndex != null || ratioIndex != null) {
      final template = templateIndex != null && templateIndex < CardTemplate.values.length
          ? CardTemplate.values[templateIndex]
          : CardTemplate.classic;
      final ratio = ratioIndex != null && ratioIndex < CardAspectRatio.values.length
          ? CardAspectRatio.values[ratioIndex]
          : CardAspectRatio.story;

      // 以模板默认配置为基础，覆盖比例
      state = ShareCardConfig.defaultFor(template).copyWith(aspectRatio: ratio);
    }
  }

  /// 持久化当前选择
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTemplate, state.template.index);
    await prefs.setInt(_keyRatio, state.aspectRatio.index);
  }

  void setTemplate(CardTemplate template) {
    // 切换模板时重置为该模板默认开关，保留当前比例
    state = ShareCardConfig.defaultFor(template).copyWith(
      aspectRatio: state.aspectRatio,
    );
    _persist();
  }

  void setAspectRatio(CardAspectRatio ratio) {
    state = state.copyWith(aspectRatio: ratio);
    _persist();
  }

  void toggleHeatmap() {
    state = state.copyWith(showHeatmap: !state.showHeatmap);
    _persist();
  }

  void toggleMapTiles() {
    state = state.copyWith(showMapTiles: !state.showMapTiles);
    _persist();
  }

  void togglePaceChart() {
    state = state.copyWith(showPaceChart: !state.showPaceChart);
    _persist();
  }

  void toggleElevationProfile() {
    state = state.copyWith(showElevationProfile: !state.showElevationProfile);
    _persist();
  }

  void toggleDataGrid() {
    state = state.copyWith(showDataGrid: !state.showDataGrid);
    _persist();
  }

  void toggleHeader() {
    state = state.copyWith(showHeader: !state.showHeader);
    _persist();
  }

  void toggleWatermark() {
    state = state.copyWith(showWatermark: !state.showWatermark);
    _persist();
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
