import 'package:flutter/material.dart';

class ConversationCard extends StatelessWidget {
  final String backgroundImagePath;

  const ConversationCard({super.key, required this.backgroundImagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190, // adjust as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(backgroundImagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // overlay to lighten the image
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // lighter overlay
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sometimes, the hardest part is starting the conversation.",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black, // darker text now
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "What’s something you’ve been carrying on your mind lately?",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87, // darker subtitle
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // handle button tap
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "Let’s talk it out! ->",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
