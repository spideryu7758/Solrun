import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/data/run_session_status.dart';
import 'package:run_pure/features/export/gpx_exporter.dart';
import 'package:run_pure/data/database.dart';

void main() {
  group('GpxExporter', () {
    final session = RunSession(
      id: 1,
      status: RunSessionStatus.completed,
      startTime: DateTime(2026, 3, 28, 7, 0),
      endTime: DateTime(2026, 3, 28, 7, 30),
      durationSeconds: 1800,
      distanceMeters: 5000,
      avgPaceSecPerKm: 360,
      bestPaceSecPerKm: 330,
      caloriesKcal: 350,
      elevationGainMeters: 45.0,
      autoName: '清晨跑',
    );

    test('生成有效的 GPX XML', () {
      final points = [
        RoutePoint(
          id: 1, sessionId: 1,
          latitude: 39.9, longitude: 116.4,
          altitude: 45.0, accuracy: 5.0, speed: 3.0,
          timestamp: DateTime(2026, 3, 28, 7, 0), orderIndex: 1,
        ),
        RoutePoint(
          id: 2, sessionId: 1,
          latitude: 39.901, longitude: 116.401,
          altitude: 46.0, accuracy: 4.0, speed: 3.2,
          timestamp: DateTime(2026, 3, 28, 7, 0, 3), orderIndex: 2,
        ),
      ];

      final gpx = GpxExporter.export(session, points);

      expect(gpx, contains('<?xml version="1.0"'));
      expect(gpx, contains('<gpx version="1.1"'));
      expect(gpx, contains('<name>清晨跑</name>'));
      expect(gpx, contains('lat="39.9"'));
      expect(gpx, contains('lon="116.4"'));
      expect(gpx, contains('<ele>45.0</ele>'));
      expect(gpx, contains('<time>'));
      expect(gpx, contains('</gpx>'));
    });

    test('无海拔时不输出 ele 标签', () {
      final points = [
        RoutePoint(
          id: 1, sessionId: 1,
          latitude: 39.9, longitude: 116.4,
          altitude: null, accuracy: 5.0, speed: 3.0,
          timestamp: DateTime(2026, 3, 28, 7, 0), orderIndex: 1,
        ),
      ];

      final gpx = GpxExporter.export(session, points);
      expect(gpx, isNot(contains('<ele>')));
    });

    test('空轨迹点生成有效 GPX（空 trkseg）', () {
      final gpx = GpxExporter.export(session, []);
      expect(gpx, contains('<trkseg>'));
      expect(gpx, contains('</trkseg>'));
      expect(gpx, contains('</gpx>'));
    });

    test('特殊字符被转义', () {
      final specialSession = RunSession(
        id: 2,
        status: RunSessionStatus.completed,
        startTime: DateTime(2026, 3, 28),
        endTime: DateTime(2026, 3, 28),
        durationSeconds: 0,
        distanceMeters: 0,
        avgPaceSecPerKm: 0,
        bestPaceSecPerKm: 0,
        caloriesKcal: 0,
        elevationGainMeters: 0,
        autoName: 'Test <&> "run"',
      );

      final gpx = GpxExporter.export(specialSession, []);
      expect(gpx, contains('Test &lt;&amp;&gt; &quot;run&quot;'));
    });
  });
}
