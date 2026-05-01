import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class CadenceSample {
  final bool available;
  final int cadenceSpm;
  final int cumulativeSteps;
  final DateTime timestamp;

  const CadenceSample({
    required this.available,
    required this.cadenceSpm,
    required this.cumulativeSteps,
    required this.timestamp,
  });
}

/// 步频传感器服务。
///
/// Android 使用原生 `TYPE_STEP_DETECTOR`，不引入额外 Flutter 依赖。
/// 传感器或权限不可用时返回 unavailable，调用方应回退 GPS 速度判断。
class StepCadenceService {
  static const _methodChannel = MethodChannel('com.runpure.run_pure/steps');
  static const _eventChannel = EventChannel('com.runpure.run_pure/step_stream');

  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<CadenceSample>.broadcast();

  Stream<CadenceSample> get cadenceStream => _controller.stream;

  Future<bool> start() async {
    if (!Platform.isAndroid) return false;

    final permission = await ph.Permission.activityRecognition.request();
    if (!permission.isGranted) {
      _controller.add(
        CadenceSample(
          available: false,
          cadenceSpm: 0,
          cumulativeSteps: 0,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }

    final isAvailable =
        await _methodChannel.invokeMethod<bool>('isAvailable') ?? false;
    if (!isAvailable) {
      _controller.add(
        CadenceSample(
          available: false,
          cadenceSpm: 0,
          cumulativeSteps: 0,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }

    await _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic data) {
        if (data is! Map) return;
        _controller.add(
          CadenceSample(
            available: data['available'] == true,
            cadenceSpm: (data['cadenceSpm'] as num?)?.toInt() ?? 0,
            cumulativeSteps: (data['cumulativeSteps'] as num?)?.toInt() ?? 0,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              (data['timestamp'] as num?)?.toInt() ??
                  DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
      },
      onError: (_) {
        _controller.add(
          CadenceSample(
            available: false,
            cadenceSpm: 0,
            cumulativeSteps: 0,
            timestamp: DateTime.now(),
          ),
        );
      },
    );
    return true;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
