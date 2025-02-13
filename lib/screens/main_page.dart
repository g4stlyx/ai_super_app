import 'package:ai_super_app/screens/chat_bot_gemini.dart';
// import 'package:ai_super_app/screens/chat_bot_gpt.dart';
import 'package:flutter/material.dart';
import 'image_recognition_screen.dart';
import 'translation_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Super App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Gemini Chat Bot'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeminiChatScreen()),
                );
              },
            ),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.chat),
            //   label: const Text('GPT Chat Bot'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            //     minimumSize: const Size(200, 50),
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const GptChatScreen()),
            //     );
            //   },
            // ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image_search),
              label: const Text('Image Recognition'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageRecognitionScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.translate),
              label: const Text('Real-time Translation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TranslationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
