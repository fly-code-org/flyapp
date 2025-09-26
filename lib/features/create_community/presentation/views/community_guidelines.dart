import 'package:flutter/material.dart';
import 'package:fly/features/create_community/controller/user_profile_controller.dart';
import 'package:fly/features/create_community/presentation/views/create_support_community.dart';
import 'package:fly/features/create_community/presentation/widgets/profile_picture_picker.dart';
import 'package:get/get.dart';

class CommunityGuidelineScreen extends StatelessWidget {
  const CommunityGuidelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.put(CommunityController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Back button + Title Row
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Change Community Guidelines",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Community Name field
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "✅ We encourage",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      maxLines: 6, // increased a bit for rules text
                      decoration: InputDecoration(
                        hint: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "1. Be Respectful: Treat all members with kindness. Assume good intent.",
                            ),
                            Text(
                              "2. Stay on Topic: Keep posts relevant to the community’s tag/theme.",
                            ),
                            Text(
                              "3. Use Trigger Warnings: Start posts with “TW:” if discussing sensitive topics.",
                            ),
                            Text(
                              "4. Support, Don’t Solve: Listen more, advise only when asked.",
                            ),
                            Text(
                              "5. Report Responsibly: Help maintain the vibe by reporting harmful content.",
                            ),
                          ],
                        ),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "❌ We discourage",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      maxLines: 6, // increased a bit for rules text
                      decoration: InputDecoration(
                        hint: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "1. No Hate Speech or Judgement: This includes body shaming, discrimination, or toxic comments.",
                            ),
                            Text(
                              "2. No Self-Promotion: Unless specifically allowed by the community admin.",
                            ),
                            Text(
                              "3. No Graphic Content: Avoid violent, sexual, or disturbing visuals.",
                            ),
                            Text(
                              "4. No Harassment or Doxxing: Don’t expose identities or provoke fights.",
                            ),
                            Text(
                              "5. No Misinformation: Especially around mental health, medication, or therapy.",
                            ),
                          ],
                        ),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "😠 We Don’t Tolerate",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.yellow,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      maxLines: 6, // increased a bit for rules text
                      decoration: InputDecoration(
                        hint: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "1. No Hate Speech or Judgement: This includes body shaming, discrimination, or toxic comments.",
                            ),
                            Text(
                              "2. No Self-Promotion: Unless specifically allowed by the community admin.",
                            ),
                            Text(
                              "3. No Graphic Content: Avoid violent, sexual, or disturbing visuals.",
                            ),
                            Text(
                              "4. No Harassment or Doxxing: Don’t expose identities or provoke fights.",
                            ),
                            Text(
                              "5. No Misinformation: Especially around mental health, medication, or therapy.",
                            ),
                          ],
                        ),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle save
                          Get.back(); // for now, just go back
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
