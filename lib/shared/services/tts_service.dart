import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 语音播报服务（单例，通过 Riverpod Provider 注入）
///
/// 统一管理系统播报（配速/距离）、观众喊话、AI 教练三条语音源，
/// 保证同一时刻只有一条语音在播放，系统播报优先级最高。
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  // ── 喊话队列管理 ──
  /// 喊话队列（最多保留 2 条，超出丢弃最旧的）
  final List<String> _shoutQueue = [];
  /// 是否正在播报（系统消息 / 喊话 / 教练，统一标记）
  bool _isSpeaking = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setCompletionHandler(_onSpeechCompleted);
      _initialized = true;
    } on Exception catch (e) {
      // TTS 初始化失败时不标记为已初始化，下次调用会重试
      debugPrint('[TtsService] 初始化失败: $e');
    }
  }

  /// 播报完成回调：恢复默认速率，调度下一条喊话
  void _onSpeechCompleted() {
    _isSpeaking = false;
    // 恢复默认播报速率（喊话可能改成了 0.6）
    _tts.setSpeechRate(0.5);
    // 检查队列中是否有待播喊话
    if (_shoutQueue.isNotEmpty) {
      final next = _shoutQueue.removeAt(0);
      _speakShoutInternal(next);
    }
  }

  /// 播报跑步状态（系统播报，优先级最高）
  Future<void> announceStatus({
    required double distanceKm,
    required int? paceSecPerKm,
    required int durationSeconds,
  }) async {
    await _ensureInit();

    final distStr = distanceKm.toStringAsFixed(1);
    final durMin = durationSeconds ~/ 60;

    String paceStr = '';
    if (paceSecPerKm != null && paceSecPerKm > 0) {
      final pMin = paceSecPerKm ~/ 60;
      final pSec = paceSecPerKm % 60;
      paceStr = '，配速每公里$pMin分${pSec > 0 ? '$pSec秒' : ''}';
    }

    final text = '已跑$distStr公里，用时$durMin分钟$paceStr';
    _shoutQueue.clear(); // 系统播报清空队列，优先级最高
    _isSpeaking = true;
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  /// 播报暂停/恢复（系统播报，自动识别语言）
  Future<void> announcePause(bool isPaused) async {
    await _ensureInit();
    _shoutQueue.clear();
    _isSpeaking = true;
    final isZh = _currentLang.startsWith('zh');
    await _tts.setLanguage(_currentLang);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(isPaused
        ? (isZh ? '暂停跑步' : 'Paused')
        : (isZh ? '继续跑步' : 'Resumed'));
  }

  /// 当前语言标识（默认中文，可通过 setLanguageTag 切换）
  String _currentLang = 'zh-CN';

  /// 设置播报语言（供外部根据 App 语言设置调用）
  void setLanguageTag(String langTag) {
    _currentLang = langTag;
  }

  /// 播报观众喊话（优先级低于系统播报）
  ///
  /// - 正在播报中 → 排队等待
  /// - 队列积压 2 条以上 → 丢弃最旧的
  /// - 播报速率稍快（speechRate 0.6）
  Future<void> speakShout(String text) async {
    await _ensureInit();

    if (_isSpeaking) {
      _shoutQueue.add(text);
      while (_shoutQueue.length > 2) {
        _shoutQueue.removeAt(0);
      }
      return;
    }

    _speakShoutInternal(text);
  }

  /// 内部喊话播报（速率稍快）
  Future<void> _speakShoutInternal(String text) async {
    _isSpeaking = true;
    // 根据内容自动检测语言（简单判断：含中文字符则用中文）
    final hasChinese = RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
    await _tts.setLanguage(hasChinese ? 'zh-CN' : 'en-US');
    await _tts.setSpeechRate(hasChinese ? 0.6 : 0.5);
    await _tts.speak(text);
  }

  /// 播报自定义文本（AI 教练等场景，优先级等同于系统播报）
  Future<void> speakCustom(String text) async {
    await _ensureInit();
    _shoutQueue.clear();
    _isSpeaking = true;
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _shoutQueue.clear();
    _isSpeaking = false;
    await _tts.stop();
  }

  void dispose() {
    _shoutQueue.clear();
    _tts.stop();
  }
}
