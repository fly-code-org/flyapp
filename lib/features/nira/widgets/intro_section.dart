import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/nira_chat_controller.dart';

class IntroSection extends StatelessWidget {
  final NiraChatController controller;
  const IntroSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/nira.png", height: 120),
            SizedBox(height: 16),
            Text(
              "Hi, I’m “Neural Interactive Response Assistant” but you can call me NIRA. I'm your personal AI buddy for mental wellness and emotional support. 😊",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 24),
            Text(
              "Is something on your mind?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => controller.startChat(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFADEEFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Start a chat.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
