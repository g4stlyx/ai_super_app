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

  Future<String> translateText(String text, String sourceLanguage, String targetLanguage) async {
    if (text.isEmpty) return '';

    try {
      final translation = await _translator.translate(
        text,
        from: sourceLanguage,
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

  Future<String> translateDocument(String documentText, String sourceLanguage, String targetLanguage) async {
    if (documentText.isEmpty) return '';

    try {
      // Split the document into smaller chunks to avoid translation API limits
      final chunks = _splitIntoChunks(documentText, 1000); // Split into 1000 character chunks
      final translatedChunks = <String>[];

      // Translate each chunk
      for (final chunk in chunks) {
        if (chunk.trim().isNotEmpty) {
          final translatedText = await translateText(
            chunk,
            sourceLanguage,
            targetLanguage,
          );
          translatedChunks.add(translatedText);

          // Add a small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // Join the translated chunks back together
      return translatedChunks.join(' ');
    } catch (e) {
      print('Document translation error: $e');
      throw Exception('Document translation failed: $e');
    }
  }

  List<String> _splitIntoChunks(String text, int chunkSize) {
    final chunks = <String>[];
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    String currentChunk = '';

    for (final sentence in sentences) {
      if ((currentChunk + sentence).length > chunkSize) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
        currentChunk = sentence;
      } else {
        currentChunk += (currentChunk.isEmpty ? '' : ' ') + sentence;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  bool get isListening => _speech.isListening;
  bool get isInitialized => _isInitialized;
}
