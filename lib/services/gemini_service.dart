import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  late final GenerativeModel _model;

  static const String _storageKey = 'chat_sessions';

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Empty response received');
      }

      return response.text!;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, String>>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => Map<String, String>.from(item)).toList();
  }

  Future<void> saveChatHistory(List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(history);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<Map<String, List<Map<String, String>>>> loadAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return {};

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((key, value) => MapEntry(
          key,
          (value as List).map((item) => Map<String, String>.from(item)).toList(),
        ));
  }

  Future<void> saveSession(String sessionId, List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadAllSessions();
    sessions[sessionId] = history;

    final String jsonString = jsonEncode(sessions);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadAllSessions();
    sessions.remove(sessionId);

    final String jsonString = jsonEncode(sessions);
    await prefs.setString(_storageKey, jsonString);
  }
}
