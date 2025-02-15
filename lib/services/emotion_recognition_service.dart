// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:face_emotion_detector/face_emotion_detector.dart';
import 'dart:io';

class EmotionRecognitionService {
  final EmotionDetector _emotionDetector = EmotionDetector();

  // Method to recognize emotion from an image
  Future<String> recognizeEmotionFromImage(File image) async {
    try {
      // Use the face emotion detector to analyze the image
      final emotions = await _emotionDetector.detectEmotionFromImage(image: image);
      if (emotions != null && emotions.isNotEmpty) {
        // Return the emotion with the highest confidence
        return emotions;
        //! for the most suitable emotion, doesnt work // return emotions.reduce((a, b) => a.confidence > b.confidence ? a : b).emotion;
      } else {
        return 'No emotions detected';
      }
    } catch (e) {
      throw Exception('Error occurred while recognizing emotion: $e');
    }
  }

  // Method to recognize emotion from text
  // Future<String> recognizeEmotionFromText(String text) async {
  //   // Prepare the request
  //   var response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'text': text}),
  //   );

  //   try {
  //     if (response.statusCode == 200) {
  //       // Parse the response
  //       var result = json.decode(response.body);
  //       return result['emotion']; // Assuming the API returns a JSON object with an 'emotion' field
  //     } else {
  //       throw Exception('Failed to recognize emotion: ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error occurred while recognizing emotion: $e');
  //   }
  // }
}
