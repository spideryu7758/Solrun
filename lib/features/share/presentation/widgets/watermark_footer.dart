import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/share_card_config.dart';
import '../../domain/share_card_data.dart';

/// 水印底部布局样式
enum WatermarkLayout {
  /// 居中排列（classic / heatmap / minimal 模板）
  center,

  /// 两端对齐（map_photo 模板）
  spaceBetween,
}

/// 分享卡片公用水印区域
///
/// 包含：观众喊话水印 + Solrun Logo + 城市天气 + 品牌 Slogan
/// 通过 [WatermarkLayout] 和颜色参数适配不同模板的视觉风格。
class WatermarkFooter extends StatelessWidget {
  final ShareCardConfig config;
  final ShareCardData data;

  /// 观众喊话与品牌行之间的间距
  final double shoutBottomSpacing;

  /// Solrun logo 字号（默认 12）
  final double logoFontSize;

  /// 喊话文字颜色
  final Color shoutColor;

  /// Solrun logo 颜色
  final Color logoColor;

  /// 城市天气文字颜色
  final Color cityWeatherColor;

  /// Slogan 文字颜色
  final Color sloganColor;

  /// 底部行布局方式
  final WatermarkLayout layout;

  /// 喊话文字的水平 padding
  final double shoutHorizontalPadding;

  /// 城市天气与 Slogan 之间的间距
  final double sloganSpacing;

  const WatermarkFooter({
    super.key,
    required this.config,
    required this.data,
    this.shoutBottomSpacing = 6,
    this.logoFontSize = 12,
    this.shoutColor = const Color(0xCC8888A8), // darkMuted * 0.8
    this.logoColor = SolrunColors.accent,
    this.cityWeatherColor = const Color(0x998888A8), // darkMuted * 0.6
    this.sloganColor = SolrunColors.darkMuted,
    this.layout = WatermarkLayout.center,
    this.shoutHorizontalPadding = 16,
    this.sloganSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.showWatermark) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 观众喊话水印
        if (config.shoutText != null) ...[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: shoutHorizontalPadding),
            child: Text(
              '"${config.shoutText}"',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: shoutColor,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: shoutBottomSpacing),
        ],

        // 品牌行：Solrun + 城市天气 + Slogan
        Row(
          mainAxisAlignment: layout == WatermarkLayout.spaceBetween
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Text(
              'Solrun',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: logoFontSize,
                color: logoColor,
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
            // 城市 + 天气
            if (data.city != null || data.weather != null) ...[
              if (layout == WatermarkLayout.center)
                SizedBox(width: sloganSpacing),
              Text(
                [data.city, data.weather]
                    .whereType<String>()
                    .join(' \u00B7 '),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 8,
                  color: cityWeatherColor,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
            if (layout == WatermarkLayout.center)
              SizedBox(width: sloganSpacing),
            Text(
              'No Ads \u00B7 Just Miles',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                color: sloganColor,
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
