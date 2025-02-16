import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FaceAnalysisService {
  final String apiKey = dotenv.env['FACE_PLUS_PLUS_API_KEY']!;
  final String apiSecret = dotenv.env['FACE_PLUS_PLUS_API_SECRET']!;
  final String apiUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';

  Future<Map<String, dynamic>> analyzeFace(File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['api_key'] = apiKey;
      request.fields['api_secret'] = apiSecret;
      request.fields['return_attributes'] = 'emotion,gender,age';
      request.files.add(await http.MultipartFile.fromPath('image_file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(String.fromCharCodes(responseData));

        if (result['faces'] != null && result['faces'].isNotEmpty) {
          var faceData = result['faces'][0]['attributes'];
          var emotions = faceData['emotion'];
          var gender = faceData['gender']['value'];
          var age = faceData['age']['value'];

          // Sort emotions by value
          var sortedEmotions = (emotions as Map<String, dynamic>).entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)); // Sort in descending order

          // Get the top emotion
          var topEmotion = sortedEmotions.first;

          return {
            'topEmotion': 'Top Emotion: ${topEmotion.key}',
            'gender': gender,
            'age': age,
          };
        } else {
          return {'error': 'No faces detected'};
        }
      } else {
        throw Exception('Failed to analyze face: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred while analyzing face: $e');
    }
  }

  Future<String> recognizeEmotionFromImage(File image) async {
    try {
      // Prepare the request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['api_key'] = apiKey;
      request.fields['api_secret'] = apiSecret;
      request.fields['return_attributes'] = 'emotion';
      request.files.add(await http.MultipartFile.fromPath('image_file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(String.fromCharCodes(responseData));

        // Check if faces are detected
        if (result['faces'] != null && result['faces'].isNotEmpty) {
          var emotions = result['faces'][0]['attributes']['emotion'];
          var sortedEmotions = (emotions as Map<String, dynamic>).entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)); // Ensure correct type for comparison
          var topEmotion = sortedEmotions.first; // Get the first entry

          return 'Top Emotion: ${topEmotion.key}';
        } else {
          return 'No faces detected';
        }
      } else {
        throw Exception('Failed to recognize emotion: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred while recognizing emotion: $e');
    }
  }
}
