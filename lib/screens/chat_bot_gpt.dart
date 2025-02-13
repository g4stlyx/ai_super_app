// import 'package:flutter/material.dart';
// import '../services/openai_service.dart';

// class GptChatScreen extends StatefulWidget {
//   const GptChatScreen({super.key});

//   @override
//   State<GptChatScreen> createState() => _GptChatScreenState();
// }

// class _GptChatScreenState extends State<GptChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, String>> _chatHistory = [];
//   final OpenAIService _openAIService = OpenAIService();
//   bool _isLoading = false;

//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     setState(() {
//       _chatHistory.add({
//         'role': 'user',
//         'content': _messageController.text,
//       });
//       _isLoading = true;
//     });

//     String userMessage = _messageController.text;
//     _messageController.clear();

//     try {
//       final response = await _openAIService.sendMessage(userMessage);

//       setState(() {
//         _chatHistory.add({
//           'role': 'assistant',
//           'content': response,
//         });
//       });
//     } catch (e) {
//       // Show error message to user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Ch4tBot'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: _chatHistory.length,
//               itemBuilder: (context, index) {
//                 final message = _chatHistory[index];
//                 final isUser = message['role'] == 'user';

//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue[100] : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(message['content'] ?? ''),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
