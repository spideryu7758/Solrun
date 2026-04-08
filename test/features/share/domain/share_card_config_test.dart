import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/features/share/domain/share_card_config.dart';

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
        final modified = original.copyWith(
          clearShout: true,
          shoutText: '新内容',
        );

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
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.paceChart),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.elevationProfile),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.dataGrid),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.header),
          isFalse,
        );
      });

      test('mapPhoto 模板支持热力/地图底图', () {
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.heatmap),
          isTrue,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.mapPhoto, ShareOption.mapTiles),
          isTrue,
        );
      });

      test('minimal 模板不支持配速图/海拔/数据网格/头部', () {
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.minimal, ShareOption.paceChart),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.minimal, ShareOption.elevationProfile),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.minimal, ShareOption.dataGrid),
          isFalse,
        );
        expect(
          ShareCardConfig.isOptionSupported(CardTemplate.minimal, ShareOption.header),
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
  });
}
