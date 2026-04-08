import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_pure/shared/utils/coord_converter.dart';

void main() {
  group('CoordConverter', () {
    group('wgs84ToGcj02 - 中国境内坐标', () {
      test('北京坐标应产生偏移', () {
        final wgs = LatLng(39.9, 116.4);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        // 中国境内坐标转换后应有偏移（通常百米级别）
        expect(gcj.latitude, isNot(equals(wgs.latitude)));
        expect(gcj.longitude, isNot(equals(wgs.longitude)));

        // 偏移量应在合理范围内（不超过 0.01 度 ≈ 1km）
        expect((gcj.latitude - wgs.latitude).abs(), lessThan(0.01));
        expect((gcj.longitude - wgs.longitude).abs(), lessThan(0.01));
      });

      test('上海坐标应产生偏移', () {
        final wgs = LatLng(31.2, 121.5);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, isNot(equals(wgs.latitude)));
        expect(gcj.longitude, isNot(equals(wgs.longitude)));
      });

      test('广州坐标应产生偏移', () {
        final wgs = LatLng(23.1, 113.3);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, isNot(equals(wgs.latitude)));
        expect(gcj.longitude, isNot(equals(wgs.longitude)));
      });
    });

    group('wgs84ToGcj02 - 中国境外坐标', () {
      test('东京坐标应原样返回（无偏移）', () {
        final wgs = LatLng(35.6, 139.7);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        // 境外坐标不做转换，应完全相等
        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });

      test('纽约坐标应原样返回', () {
        final wgs = LatLng(40.7, -74.0);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });

      test('伦敦坐标应原样返回', () {
        final wgs = LatLng(51.5, -0.1);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });
    });

    group('wgs84ToGcj02 - 边界值测试', () {
      test('中国南边界附近（纬度 3.86）应有偏移', () {
        final wgs = LatLng(3.86, 110.0);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, isNot(equals(wgs.latitude)));
      });

      test('中国北边界附近（纬度 53.55）应有偏移', () {
        final wgs = LatLng(53.55, 110.0);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, isNot(equals(wgs.latitude)));
      });

      test('纬度低于南边界（3.85）应原样返回', () {
        final wgs = LatLng(3.85, 110.0);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });

      test('经度高于东边界（135.06）应原样返回', () {
        final wgs = LatLng(39.9, 135.06);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });

      test('经度低于西边界（73.65）应原样返回', () {
        final wgs = LatLng(39.9, 73.65);
        final gcj = CoordConverter.wgs84ToGcj02(wgs);

        expect(gcj.latitude, equals(wgs.latitude));
        expect(gcj.longitude, equals(wgs.longitude));
      });
    });

    group('wgs84ToGcj02List - 批量转换', () {
      test('空列表返回空列表', () {
        final result = CoordConverter.wgs84ToGcj02List([]);
        expect(result, isEmpty);
      });

      test('批量转换结果数量与输入一致', () {
        final points = [
          LatLng(39.9, 116.4),
          LatLng(31.2, 121.5),
          LatLng(35.6, 139.7), // 境外
        ];
        final result = CoordConverter.wgs84ToGcj02List(points);

        expect(result.length, equals(3));
        // 前两个（中国境内）应有偏移
        expect(result[0].latitude, isNot(equals(points[0].latitude)));
        expect(result[1].latitude, isNot(equals(points[1].latitude)));
        // 第三个（境外）应无偏移
        expect(result[2].latitude, equals(points[2].latitude));
      });

      test('批量转换结果与逐个转换一致', () {
        final points = [
          LatLng(39.9, 116.4),
          LatLng(23.1, 113.3),
        ];
        final batchResult = CoordConverter.wgs84ToGcj02List(points);
        final singleResults = points.map(CoordConverter.wgs84ToGcj02).toList();

        for (int i = 0; i < points.length; i++) {
          expect(batchResult[i].latitude, equals(singleResults[i].latitude));
          expect(batchResult[i].longitude, equals(singleResults[i].longitude));
        }
      });
    });

    group('转换一致性', () {
      test('相同输入应产生相同输出（纯函数）', () {
        final wgs = LatLng(39.9, 116.4);
        final result1 = CoordConverter.wgs84ToGcj02(wgs);
        final result2 = CoordConverter.wgs84ToGcj02(wgs);

        expect(result1.latitude, equals(result2.latitude));
        expect(result1.longitude, equals(result2.longitude));
      });
    });
  });
}
