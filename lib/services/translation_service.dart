// ignore_for_file: avoid_print

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class TranslationService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isInitialized = false;

  Future<bool> initializeSpeech({
    required void Function(String) onStatus,
    required void Function(dynamic) onError,
  }) async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) => onError(error.errorMsg),
      onStatus: onStatus,
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      throw Exception('Speech recognition not initialized');
    }

    if (!_speech.isListening) {
      await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
      );
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return '';

    try {
      final translation = await _translator.translate(
        text,
        from: 'en',
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      print('Translation error details: $e');
      throw Exception('Translation failed: $e');
    }
  }

  Future<void> speak(String text, String language) async {
    if (text.isEmpty) return;

    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('Text-to-speech failed: $e');
    }
  }

  bool get isListening => _speech.isListening;
  bool get isInitialized => _isInitialized;
}
