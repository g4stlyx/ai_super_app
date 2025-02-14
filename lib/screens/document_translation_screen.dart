// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/translation_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TranslationService _translationService = TranslationService();
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';

  Future<void> _pickAndReadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase() ?? '';
        String contents = '';

        switch (extension) {
          case 'pdf':
            contents = await _readPdfFile(file);
            break;
          case 'txt':
            contents = await file.readAsString();
            break;
          case 'doc':
          case 'docx':
            // Show message that DOC/DOCX support is coming soon
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('DOC/DOCX support coming soon. Please convert to PDF or TXT for now.'),
              ),
            );
            return;
          default:
            throw Exception('Unsupported file type');
        }

        setState(() {
          _textController.text = contents;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading file: $e')),
      );
    }
  }

  Future<String> _readPdfFile(File file) async {
    try {
      final text = await ReadPdfText.getPDFtext(file.path);
      return text;
    } catch (e) {
      throw Exception('Error reading PDF: $e');
    }
  }

  Future<void> _translateDocument() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      final translated = await _translationService.translateDocument(
        _textController.text,
        _sourceLanguage,
        _targetLanguage,
      );

      setState(() {
        _translatedText = translated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation error: $e')),
      );
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Translation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sourceLanguage,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      // Add more languages as needed
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sourceLanguage = value!;
                      });
                    },
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: DropdownButton<String>(
                    value: _targetLanguage,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      // Add more languages as needed
                    ],
                    onChanged: (value) {
                      setState(() {
                        _targetLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickAndReadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document (PDF, TXT)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter or paste text here...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTranslating ? null : _translateDocument,
              child: _isTranslating ? const CircularProgressIndicator() : const Text('Translate'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(_translatedText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
