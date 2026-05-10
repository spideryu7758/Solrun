import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_pure/data/database.dart';
import 'package:run_pure/features/share/domain/share_card_config.dart';
import 'package:run_pure/features/share/domain/share_card_data.dart';
import 'package:run_pure/features/share/presentation/templates/minimal_template.dart';
import 'package:run_pure/features/share/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ShareCardConfig', () {
    group('defaultFor', () {
      test('classic 模板默认值正确', () {
        final config = ShareCardConfig.defaultFor(CardTemplate.classic);
        expect(config.template, equals(CardTemplate.classic));
        expect(config.showHeatmap, isTrue);
        expect(config.showMapTiles, isFalse);
        expect(config.showPaceChart, isFalse);
        expect(config.showElevationProfile, isFalse);
        expect(config.showDataGrid, isTrue);
        expect(config.showHeader, isTrue);
        expect(config.showWatermark, isTrue);
        expect(config.showDataEntertainment, isFalse);
      });

      test('heatmap 模板默认开启配速图和海拔剖面', () {
        final config = ShareCardConfig.defaultFor(CardTemplate.heatmap);
        expect(config.template, equals(CardTemplate.heatmap));
        expect(config.showHeatmap, isTrue);
        expect(config.showPaceChart, isTrue);
        expect(config.showElevationProfile, isTrue);
        expect(config.showDataGrid, isTrue);
        expect(config.showHeader, isTrue);
      });

      test('mapPhoto 模板默认开启地图底图', () {
        final config = ShareCardConfig.defaultFor(CardTemplate.mapPhoto);
        expect(config.template, equals(CardTemplate.mapPhoto));
        expect(config.showMapTiles, isTrue);
        expect(config.showHeatmap, isTrue);
        expect(config.showDataGrid, isFalse);
        expect(config.showHeader, isFalse);
      });

      test('模板默认配置不启用不支持的选项', () {
        for (final template in CardTemplate.values) {
          final config = ShareCardConfig.defaultFor(template);
          final expectations = <ShareOption, bool>{
            ShareOption.mapTiles: config.showMapTiles,
            ShareOption.paceChart: config.showPaceChart,
            ShareOption.elevationProfile: config.showElevationProfile,
            ShareOption.dataGrid: config.showDataGrid,
            ShareOption.header: config.showHeader,
            ShareOption.dataEntertainment: config.showDataEntertainment,
          };

          for (final entry in expectations.entries) {
            if (entry.value) {
              expect(
                ShareCardConfig.isOptionSupported(template, entry.key),
                isTrue,
                reason: '${template.name}.${entry.key.name} 默认开启但不支持',
              );
            }
          }
        }
      });

      test('minimal 模板默认关闭数据网格和头部', () {
        final config = ShareCardConfig.defaultFor(CardTemplate.minimal);
        expect(config.template, equals(CardTemplate.minimal));
        expect(config.showDataGrid, isFalse);
        expect(config.showHeader, isFalse);
        expect(config.showHeatmap, isTrue);
        expect(config.showWatermark, isTrue);
      });
    });

    group('copyWith 不可变性', () {
      test('copyWith 返回新对象，不修改原对象', () {
        final original = const ShareCardConfig();
        final modified = original.copyWith(showHeatmap: false);

        expect(original.showHeatmap, isTrue); // 原对象未改变
        expect(modified.showHeatmap, isFalse); // 新对象已改变
      });

      test('copyWith 可开启数据娱乐化', () {
        final original = const ShareCardConfig();
        final modified = original.copyWith(showDataEntertainment: true);

        expect(original.showDataEntertainment, isFalse);
        expect(modified.showDataEntertainment, isTrue);
      });

      test('copyWith 未指定的字段保持原值', () {
        final original = const ShareCardConfig(
          template: CardTemplate.heatmap,
          showPaceChart: true,
          showElevationProfile: true,
        );
        final modified = original.copyWith(showPaceChart: false);

        expect(modified.template, equals(CardTemplate.heatmap));
        expect(modified.showPaceChart, isFalse);
        expect(modified.showElevationProfile, isTrue); // 未修改的字段保持
      });

      test('copyWith 可修改模板和比例', () {
        final original = const ShareCardConfig();
        final modified = original.copyWith(
          template: CardTemplate.minimal,
          aspectRatio: CardAspectRatio.square,
        );

        expect(modified.template, equals(CardTemplate.minimal));
        expect(modified.aspectRatio, equals(CardAspectRatio.square));
      });

      test('copyWith shout 字段', () {
        final original = const ShareCardConfig(
          shoutText: '加油！',
          shoutRole: '尖叫粉',
        );
        final modified = original.copyWith(shoutText: '冲刺！');

        expect(modified.shoutText, equals('冲刺！'));
        expect(modified.shoutRole, equals('尖叫粉')); // 未修改
      });

      test('copyWith clearShout 清除喊话内容', () {
        final original = const ShareCardConfig(
          shoutText: '加油！',
          shoutRole: '尖叫粉',
        );
        final modified = original.copyWith(clearShout: true);

        expect(modified.shoutText, isNull);
        expect(modified.shoutRole, isNull);
      });

      test('clearShout 优先于 shoutText 参数', () {
        final original = const ShareCardConfig(
          shoutText: '加油！',
          shoutRole: '尖叫粉',
        );
        // 同时传 clearShout=true 和 shoutText，clearShout 优先
        final modified = original.copyWith(clearShout: true, shoutText: '新内容');

        expect(modified.shoutText, isNull);
        expect(modified.shoutRole, isNull);
      });
    });

    group('isOptionSupported', () {
      test('classic 模板默认支持所有选项', () {
        for (final option in ShareOption.values) {
          expect(
            ShareCardConfig.isOptionSupported(CardTemplate.classic, option),
            isTrue,
            reason: 'classic 应支持 ${option.name}',
          );
        }
      });

      test('classic 模板 1:1 比例不支持地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.classic,
            ShareOption.mapTiles,
            aspectRatio: CardAspectRatio.square,
          ),
          isFalse,
        );
      });

      test('classic 模板 9:16 比例支持地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.classic,
            ShareOption.mapTiles,
            aspectRatio: CardAspectRatio.story,
          ),
          isTrue,
        );
      });

      test('heatmap 模板 1:1 比例不支持地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.heatmap,
            ShareOption.mapTiles,
            aspectRatio: CardAspectRatio.square,
          ),
          isFalse,
        );
      });

      test('mapPhoto 模板不支持配速图/海拔/数据网格/头部', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.paceChart,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.elevationProfile,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.dataGrid,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.header,
          ),
          isFalse,
        );
      });

      test('mapPhoto 模板支持热力/地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.heatmap,
          ),
          isTrue,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.mapTiles,
          ),
          isTrue,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.mapPhoto,
            ShareOption.dataEntertainment,
          ),
          isTrue,
        );
      });

      test('minimal 模板不支持配速图/海拔/数据网格/头部', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.paceChart,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.elevationProfile,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.dataGrid,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.header,
          ),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.dataEntertainment,
          ),
          isFalse,
        );
      });

      test('minimal 模板 1:1 比例不支持地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.mapTiles,
            aspectRatio: CardAspectRatio.square,
          ),
          isFalse,
        );
      });

      test('minimal 模板 9:16 比例支持地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(
            CardTemplate.minimal,
            ShareOption.mapTiles,
            aspectRatio: CardAspectRatio.story,
          ),
          isTrue,
        );
      });
    });

    group('CardAspectRatio', () {
      test('ratio 计算正确', () {
        expect(CardAspectRatio.story.ratio, equals(9 / 16));
        expect(CardAspectRatio.square.ratio, equals(1.0));
        expect(CardAspectRatio.portrait.ratio, equals(3 / 4));
      });

      test('label 正确', () {
        expect(CardAspectRatio.story.label, equals('9:16'));
        expect(CardAspectRatio.square.label, equals('1:1'));
        expect(CardAspectRatio.portrait.label, equals('3:4'));
      });
    });

    group('CardTemplate', () {
      test('label 中文名正确', () {
        expect(CardTemplate.classic.label, equals('经典'));
        expect(CardTemplate.heatmap.label, equals('热力'));
        expect(CardTemplate.mapPhoto.label, equals('地图'));
        expect(CardTemplate.minimal.label, equals('极简'));
      });
    });

    group('ShareCardData.formatPaceSeconds', () {
      test('普通格式正常进位', () {
        expect(ShareCardData.formatPaceSeconds(374), equals('6\'14"'));
        expect(ShareCardData.formatPaceSeconds(428), equals('7\'08"'));
      });

      test('数据娱乐化固定为 5 分并把多出的分钟折进秒数', () {
        expect(
          ShareCardData.formatPaceSeconds(374, dataEntertainment: true),
          equals('5\'74"'),
        );
        expect(
          ShareCardData.formatPaceSeconds(428, dataEntertainment: true),
          equals('5\'128"'),
        );
      });

      test('数据娱乐化低于 5 分时不会显示负秒数', () {
        expect(
          ShareCardData.formatPaceSeconds(285, dataEntertainment: true),
          equals('5\'00"'),
        );
        expect(ShareCardData.entertainmentPaceExtraSeconds(285), equals(0));
        expect(ShareCardData.entertainmentPaceDisplaySeconds(285), equals(300));
      });

      test('数据娱乐化图表秒数保留 5 分基线', () {
        expect(ShareCardData.entertainmentPaceDisplaySeconds(285), equals(300));
        expect(ShareCardData.entertainmentPaceDisplaySeconds(374), equals(374));
      });
    });

    group('ShareCardNotifier', () {
      test('恢复已持久化的数据娱乐化开关', () async {
        SharedPreferences.setMockInitialValues({
          'share_template': CardTemplate.heatmap.index,
          'share_ratio': CardAspectRatio.portrait.index,
          'share_data_entertainment': true,
        });
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(shareCardConfigProvider);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        expect(config.template, CardTemplate.heatmap);
        expect(config.aspectRatio, CardAspectRatio.portrait);
        expect(config.showDataEntertainment, isTrue);
      });

      test('恢复不支持模板时清退数据娱乐化开关', () async {
        SharedPreferences.setMockInitialValues({
          'share_template': CardTemplate.minimal.index,
          'share_ratio': CardAspectRatio.story.index,
          'share_data_entertainment': true,
        });
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(shareCardConfigProvider);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        final prefs = await SharedPreferences.getInstance();
        expect(config.template, CardTemplate.minimal);
        expect(config.showDataEntertainment, isFalse);
        expect(prefs.getBool('share_data_entertainment'), isFalse);
      });

      test('恢复负数枚举索引时回退默认值并回写', () async {
        SharedPreferences.setMockInitialValues({
          'share_template': -1,
          'share_ratio': -1,
        });
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(shareCardConfigProvider);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        final prefs = await SharedPreferences.getInstance();
        expect(config.template, CardTemplate.classic);
        expect(config.aspectRatio, CardAspectRatio.story);
        expect(prefs.getInt('share_template'), CardTemplate.classic.index);
        expect(prefs.getInt('share_ratio'), CardAspectRatio.story.index);
      });

      test('切换数据娱乐化时写入持久化状态', () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(shareCardConfigProvider.notifier)
            .toggleDataEntertainment();
        await Future<void>.delayed(Duration.zero);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('share_data_entertainment'), isTrue);
      });

      test('恢复已持久化的自定义开关', () async {
        SharedPreferences.setMockInitialValues({
          'share_template': CardTemplate.classic.index,
          'share_ratio': CardAspectRatio.story.index,
          'share_show_map_tiles': true,
          'share_show_pace_chart': true,
          'share_show_elevation_profile': true,
          'share_show_data_grid': false,
          'share_show_header': false,
          'share_show_watermark': false,
        });
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(shareCardConfigProvider);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        expect(config.showMapTiles, isTrue);
        expect(config.showPaceChart, isTrue);
        expect(config.showElevationProfile, isTrue);
        expect(config.showDataGrid, isFalse);
        expect(config.showHeader, isFalse);
        expect(config.showWatermark, isFalse);
      });

      test('切换到支持的模板时保留数据娱乐化开关', () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(shareCardConfigProvider.notifier);
        notifier.toggleDataEntertainment();
        await Future<void>.delayed(Duration.zero);
        notifier.setTemplate(CardTemplate.heatmap);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        final prefs = await SharedPreferences.getInstance();
        expect(config.template, CardTemplate.heatmap);
        expect(config.showDataEntertainment, isTrue);
        expect(prefs.getBool('share_data_entertainment'), isTrue);
      });

      test('切换到不支持的模板时关闭数据娱乐化开关', () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(shareCardConfigProvider.notifier);
        notifier.toggleDataEntertainment();
        await Future<void>.delayed(Duration.zero);
        notifier.setTemplate(CardTemplate.minimal);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        final prefs = await SharedPreferences.getInstance();
        expect(config.template, CardTemplate.minimal);
        expect(config.showDataEntertainment, isFalse);
        expect(prefs.getBool('share_data_entertainment'), isFalse);
      });

      test('切换到不支持地图底图的比例时关闭地图底图', () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(shareCardConfigProvider.notifier);
        notifier.toggleMapTiles();
        await Future<void>.delayed(Duration.zero);
        notifier.setAspectRatio(CardAspectRatio.square);
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        expect(config.template, CardTemplate.classic);
        expect(config.aspectRatio, CardAspectRatio.square);
        expect(config.showMapTiles, isFalse);
      });

      test('不支持模板下直接切换数据娱乐化不会写入脏状态', () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(shareCardConfigProvider.notifier);
        notifier.setTemplate(CardTemplate.minimal);
        await Future<void>.delayed(Duration.zero);
        notifier.toggleDataEntertainment();
        await Future<void>.delayed(Duration.zero);

        final config = container.read(shareCardConfigProvider);
        final prefs = await SharedPreferences.getInstance();
        expect(config.template, CardTemplate.minimal);
        expect(config.showDataEntertainment, isFalse);
        expect(prefs.getBool('share_data_entertainment'), isFalse);
      });
    });

    group('MinimalTemplate', () {
      testWidgets('默认不渲染头部身份和日期', (tester) async {
        final startTime = DateTime(2026, 1, 2, 3, 4);
        final data = ShareCardData(
          session: RunSession(
            id: 1,
            status: 'completed',
            startTime: startTime,
            durationSeconds: 1800,
            distanceMeters: 1000,
            avgPaceSecPerKm: 360,
            bestPaceSecPerKm: 330,
            caloriesKcal: 100,
            elevationGainMeters: 0,
            autoName: 'Test Run',
          ),
          points: const [],
          splits: const [],
          nickname: 'Private Runner',
          speeds: const [],
          segmentColors: const [],
          mergedSegments: const [],
          altitudes: const [],
          recalculatedElevationGain: 0,
          minLat: 0,
          maxLat: 0,
          minLng: 0,
          maxLng: 0,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MinimalTemplate(
              data: data,
              config: ShareCardConfig.defaultFor(CardTemplate.minimal),
              cardWidth: 360,
              cardHeight: 640,
            ),
          ),
        );

        expect(find.text('Private Runner'), findsNothing);
        expect(find.text('2026/01/02 03:04'), findsNothing);
      });
    });
  });
}
