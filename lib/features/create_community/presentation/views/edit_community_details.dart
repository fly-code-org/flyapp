import 'package:flutter/material.dart';
import 'package:fly/features/create_community/controller/user_profile_controller.dart';
import 'package:fly/features/create_community/presentation/views/create_support_community.dart';
import 'package:fly/features/create_community/presentation/widgets/profile_picture_picker.dart';
import 'package:get/get.dart';

class EditCommunityScreen extends StatelessWidget {
  const EditCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.put(CommunityController());

    // Hardcoded lists
    final supportedTags = [
      SupportCommunity(name: "Emotional Healing", icon: Icons.healing),
      SupportCommunity(
        name: "Anxiety & Stress",
        icon: Icons.sentiment_dissatisfied,
      ),
      SupportCommunity(name: "Grief & Heartbreak", icon: Icons.heart_broken),
      SupportCommunity(name: "Work & Career", icon: Icons.work),
      SupportCommunity(name: "Trauma", icon: Icons.local_hospital),
      SupportCommunity(name: "Family & Relations", icon: Icons.family_restroom),
      SupportCommunity(name: "Self-Worth & Identity", icon: Icons.person),
    ];

    final socialTags = [
      SupportCommunity(name: "Motivational", icon: Icons.lightbulb),
      SupportCommunity(name: "Awwdorable", icon: Icons.pets),
      SupportCommunity(name: "Fun & Humour", icon: Icons.emoji_emotions),
      SupportCommunity(name: "Peace", icon: Icons.spa),
      SupportCommunity(name: "Words Of Wisdom", icon: Icons.menu_book),
      SupportCommunity(name: "News & Insights", icon: Icons.article),
      SupportCommunity(name: "Movies & Shows", icon: Icons.movie),
    ];

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
                  "Manage Community",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 👇 Profile Image with camera overlay (only for this screen)
            Center(
              child: Stack(
                children: [
                  ProfileImagePicker(
                    role: "mhp",
                    onImagePicked: (file) {
                      controller.selectedImage.value = file;
                    },
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
                      "Update Community Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter community name",
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
                    SupportCommunityPicker(
                      tags: supportedTags,
                      isSocial: false,
                      defaultTag: SupportCommunity(
                        name: "Grief & Heartbreak",
                        icon: Icons.heart_broken,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Update Community Bio",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter community name",
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
                      "Change Community Guidelines",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
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
