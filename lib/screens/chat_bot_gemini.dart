// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  // Add new state variables
  late String _currentSessionId;
  Map<String, List<Map<String, String>>> _sessions = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _geminiService.loadAllSessions();
    setState(() {
      _sessions = sessions;
      // Create a new session if none exists
      if (_sessions.isEmpty) {
        _currentSessionId = _generateSessionId();
        _sessions[_currentSessionId] = [];
      } else {
        _currentSessionId = _sessions.keys.first;
      }
      _chatHistory.clear();
      _chatHistory.addAll(_sessions[_currentSessionId]!);
    });
  }

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _createNewSession() async {
    final newSessionId = _generateSessionId();
    setState(() {
      _currentSessionId = newSessionId;
      _sessions[newSessionId] = [];
      _chatHistory.clear();
    });
    await _geminiService.saveSession(newSessionId, []);
  }

  Future<void> _switchSession(String sessionId) async {
    setState(() {
      _currentSessionId = sessionId;
      _chatHistory.clear();
      _chatHistory.addAll(_sessions[sessionId]!);
    });
  }

  Future<void> _deleteCurrentSession() async {
    await _geminiService.deleteSession(_currentSessionId);
    setState(() {
      _sessions.remove(_currentSessionId);
      if (_sessions.isEmpty) {
        _createNewSession();
      } else {
        _currentSessionId = _sessions.keys.first;
        _chatHistory.clear();
        _chatHistory.addAll(_sessions[_currentSessionId]!);
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({
        'role': 'user',
        'content': _messageController.text,
      });
      _isLoading = true;
    });

    String userMessage = _messageController.text;
    _messageController.clear();

    try {
      final response = await _geminiService.sendMessage(userMessage);

      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': response,
        });
      });
      // Save the current session
      await _geminiService.saveSession(_currentSessionId, _chatHistory);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gemini Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewSession,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: _switchSession,
            itemBuilder: (BuildContext context) {
              return _sessions.keys.map((String sessionId) {
                return PopupMenuItem<String>(
                  value: sessionId,
                  child: Row(
                    children: [
                      Text('Chat ${sessionId.substring(sessionId.length - 4)}'),
                      if (sessionId == _currentSessionId) const Icon(Icons.check, size: 16),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _sessions.length > 1 ? _deleteCurrentSession : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['content'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
