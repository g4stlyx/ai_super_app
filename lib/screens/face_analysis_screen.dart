// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/face_analysis_service.dart';

class FaceAnalysisScreen extends StatefulWidget {
  const FaceAnalysisScreen({super.key});

  @override
  _FaceAnalysisScreenState createState() => _FaceAnalysisScreenState();
}

class _FaceAnalysisScreenState extends State<FaceAnalysisScreen> {
  final FaceAnalysisService _service = FaceAnalysisService();
  String _recognizedEmotion = 'No emotion recognized';
  String _gender = 'Unknown';
  String _age = 'Unknown';
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _analyzeFace();
    }
  }

  Future<void> _analyzeFace() async {
    if (_image != null) {
      var analysisResult = await _service.analyzeFace(_image!);
      setState(() {
        if (analysisResult.containsKey('error')) {
          _recognizedEmotion = analysisResult['error'];
          _gender = 'Unknown';
          _age = 'Unknown';
        } else {
          _recognizedEmotion = analysisResult['topEmotion'];
          _gender = analysisResult['gender'];
          _age = analysisResult['age'].toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? const Text('No image selected.') : Image.file(_image!),
            const SizedBox(height: 20),
            Text(
              _recognizedEmotion,
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              'Gender: $_gender',
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              'Age: $_age',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Pick from Gallery'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Capture with Camera'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
