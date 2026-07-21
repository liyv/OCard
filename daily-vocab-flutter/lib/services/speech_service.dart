import 'package:flutter_tts/flutter_tts.dart';

/// 语音合成服务 - 提供英语和日语的 TTS 发音
class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// 初始化 TTS 引擎
  Future<void> init() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  /// 播放英语发音
  Future<void> speakEnglish(String text) async {
    await init();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.speak(text);
  }

  /// 播放日语发音
  Future<void> speakJapanese(String text) async {
    await init();
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.speak(text);
  }

  /// 停止发音
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// 获取可用语言列表
  Future<List<String>> getAvailableLanguages() async {
    await init();
    // 注意：实际使用中需要检查设备支持的语言
    return ['en-US', 'ja-JP'];
  }

  /// 释放资源
  Future<void> dispose() async {
    await _flutterTts.stop();
    await _flutterTts.shutdown();
    _isInitialized = false;
  }
}
