/// 分享卡片模板
enum CardTemplate {
  classic,   // 经典（当前样式升级）
  heatmap,   // 热力强调
  mapPhoto,  // 地图底图 + 叠加
  minimal;   // 极简

  /// 各模板的中文名称
  String get label => switch (this) {
    classic => '经典',
    heatmap => '热力',
    mapPhoto => '地图',
    minimal => '极简',
  };
}

/// 分享卡片比例
enum CardAspectRatio {
  story(9, 16, '9:16'),     // 故事/朋友圈
  square(1, 1, '1:1'),      // 朋友圈方图
  portrait(3, 4, '3:4');    // 竖版

  final int w;
  final int h;
  final String label;
  const CardAspectRatio(this.w, this.h, this.label);
  double get ratio => w / h;
}

/// 自定义选项标识（用于能力查询）
enum ShareOption {
  heatmap,
  mapTiles,
  paceChart,
  elevationProfile,
  dataGrid,
  header,
}

/// 分享卡片配置（不可变）
class ShareCardConfig {
  final CardTemplate template;
  final CardAspectRatio aspectRatio;
  final bool showHeatmap;
  final bool showMapTiles;
  final bool showPaceChart;
  final bool showElevationProfile;
  final bool showDataGrid;
  final bool showHeader;
  final bool showWatermark;
  final String? shoutText;  // 观众喊话水印内容
  final String? shoutRole;  // 观众角色名

  const ShareCardConfig({
    this.template = CardTemplate.classic,
    this.aspectRatio = CardAspectRatio.story,
    this.showHeatmap = true,
    this.showMapTiles = false,
    this.showPaceChart = false,
    this.showElevationProfile = false,
    this.showDataGrid = true,
    this.showHeader = true,
    this.showWatermark = true,
    this.shoutText,
    this.shoutRole,
  });

  ShareCardConfig copyWith({
    CardTemplate? template,
    CardAspectRatio? aspectRatio,
    bool? showHeatmap,
    bool? showMapTiles,
    bool? showPaceChart,
    bool? showElevationProfile,
    bool? showDataGrid,
    bool? showHeader,
    bool? showWatermark,
    String? shoutText,
    String? shoutRole,
    bool clearShout = false,
  }) {
    return ShareCardConfig(
      template: template ?? this.template,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      showMapTiles: showMapTiles ?? this.showMapTiles,
      showPaceChart: showPaceChart ?? this.showPaceChart,
      showElevationProfile: showElevationProfile ?? this.showElevationProfile,
      showDataGrid: showDataGrid ?? this.showDataGrid,
      showHeader: showHeader ?? this.showHeader,
      showWatermark: showWatermark ?? this.showWatermark,
      shoutText: clearShout ? null : (shoutText ?? this.shoutText),
      shoutRole: clearShout ? null : (shoutRole ?? this.shoutRole),
    );
  }

  /// 各模板的默认配置
  static ShareCardConfig defaultFor(CardTemplate template) {
    return switch (template) {
      CardTemplate.classic => const ShareCardConfig(
        template: CardTemplate.classic,
        showHeatmap: true,
        showMapTiles: false,
        showPaceChart: false,
        showElevationProfile: false,
        showDataGrid: true,
        showHeader: true,
        showWatermark: true,
      ),
      CardTemplate.heatmap => const ShareCardConfig(
        template: CardTemplate.heatmap,
        showHeatmap: true,
        showMapTiles: false,
        showPaceChart: true,
        showElevationProfile: true,
        showDataGrid: true,
        showHeader: true,
        showWatermark: true,
      ),
      CardTemplate.mapPhoto => const ShareCardConfig(
        template: CardTemplate.mapPhoto,
        showHeatmap: true,
        showMapTiles: true,
        showPaceChart: false,
        showElevationProfile: false,
        showDataGrid: true,
        showHeader: true,
        showWatermark: true,
      ),
      CardTemplate.minimal => const ShareCardConfig(
        template: CardTemplate.minimal,
        showHeatmap: true,
        showMapTiles: false,
        showPaceChart: false,
        showElevationProfile: false,
        showDataGrid: false,
        showHeader: false,
        showWatermark: true,
      ),
    };
  }

  /// 判断当前模板（含比例）是否支持某个自定义选项
  static bool isOptionSupported(
    CardTemplate template,
    ShareOption option, {
    CardAspectRatio? aspectRatio,
  }) {
    return switch (template) {
      // 经典：1:1 比例下轨迹区域太小，不支持地图底图
      CardTemplate.classic => switch (option) {
        ShareOption.mapTiles when aspectRatio == CardAspectRatio.square => false,
        _ => true,
      },
      // 热力：1:1 比例下地图区域太小，不支持地图底图
      CardTemplate.heatmap => switch (option) {
        ShareOption.mapTiles when aspectRatio == CardAspectRatio.square => false,
        _ => true,
      },
      // 地图模板：不支持配速图、海拔、数据网格、头部信息
      CardTemplate.mapPhoto => switch (option) {
        ShareOption.paceChart => false,
        ShareOption.elevationProfile => false,
        ShareOption.dataGrid => false,
        ShareOption.header => false,
        _ => true,
      },
      // 极简：不支持配速图、海拔、数据网格、头部信息；1:1 比例下不支持地图底图
      CardTemplate.minimal => switch (option) {
        ShareOption.paceChart => false,
        ShareOption.elevationProfile => false,
        ShareOption.dataGrid => false,
        ShareOption.header => false,
        ShareOption.mapTiles when aspectRatio == CardAspectRatio.square => false,
        _ => true,
      },
    };
  }
}
