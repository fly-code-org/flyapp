import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/nira_chat_controller.dart';

class IntroSection extends StatelessWidget {
  final NiraChatController controller;
  const IntroSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingSession.value;
      return Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/nira.png", height: 120),
                  const SizedBox(height: 16),
                  Text(
                    'Hi, I\'m "Neural Interactive Response Assistant" but you can call me NIRA. I\'m your personal AI buddy for mental wellness and emotional support. 😊',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Is something on your mind?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: isLoading ? null : () => controller.startChat(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFADEEFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Start a chat.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
