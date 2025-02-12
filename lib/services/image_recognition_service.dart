import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageRecognitionService {
  Future<String> analyzeImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());

      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      String resultText = 'Found objects:\n\n';
      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence * 100;
        resultText += '• $text (${confidence.toStringAsFixed(2)}%)\n';
      }

      imageLabeler.close();
      return resultText;
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
}
