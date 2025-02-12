import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini	',
          'messages': [
            {'role': 'user', 'content': message}
          ],
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //* can be used for image analysis but there is a free alternative to it: google ml kit

  // Future<String> analyzeImage(String imagePath) async {
  //   try {
  //     final bytes = await File(imagePath).readAsBytes();
  //     final base64Image = base64Encode(bytes);

  //     final response = await http.post(
  //       Uri.parse('https://api.openai.com/v1/chat/completions'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
  //       },
  //       body: jsonEncode({
  //         'model': 'gpt-4-vision-preview',
  //         'messages': [
  //           {
  //             'role': 'user',
  //             'content': [
  //               {'type': 'text', 'text': 'What\'s in this image? Please describe it in detail.'},
  //               {
  //                 'type': 'image_url',
  //                 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
  //               }
  //             ]
  //           }
  //         ],
  //         'max_tokens': 300
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['choices'][0]['message']['content'];
  //     } else {
  //       throw Exception('Failed to analyze image: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error analyzing image: $e');
  //   }
  // }
}
