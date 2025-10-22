import 'package:flutter/material.dart';
import 'package:fly/features/create_community/controller/user_profile_controller.dart';
import 'package:fly/features/explore/presentation/widgets/community_list_horizontal.dart';
import 'package:fly/features/explore/presentation/widgets/conversation_card.dart';
import 'package:fly/features/explore/presentation/widgets/search_bar.dart';
import 'package:fly/features/explore/presentation/widgets/social_tag_h.dart';
import 'package:fly/features/user_profile/presentation/widgets/bottom_navbar.dart';
import 'package:get/get.dart';

class ExploreScreen extends StatelessWidget {
  ExploreScreen({super.key}); // no const

  // ✅ Use asset paths instead of network URLs
  final List<Map<String, String>> socialTags = [
    {
      "categoryLabel": "Respect",
      "imagePath": "assets/icon/social-tags/artAndCreativity.svg",
      "rightText": "Art & Creativity",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/awdorable.svg",
      "rightText": "Awwdorable",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/funAndHumor.svg",
      "rightText": "Fun & Humor",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/lifestyle.svg",
      "rightText": "Lifestyle",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/motivational.svg",
      "rightText": "Motivational",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/moviesAndShows.svg",
      "rightText": "Movies & Shows",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/newsAndInsights.svg",
      "rightText": "News & Insights",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/peace.svg",
      "rightText": "Peace",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/wordsOfWisdom.svg",
      "rightText": "Words of Wisdom",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.put(CommunityController());
    int _currentIndex = 1;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Title Row
            Row(
              children: const [
                SizedBox(width: 20),
                Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                SizedBox(width: 20),
                Text(
                  "MHPs, tags, communities and more... ",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: CustomSearchBar(
                    controller: TextEditingController(),
                    onChanged: (value) {
                      print("Searching: $value");
                    },
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),

            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConversationCard(
                      backgroundImagePath: 'assets/images/bg_fly.png',
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Select a Social tag and discover like contents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: socialTags.map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SocialTagHorizontal(
                                categoryLabel: tag["categoryLabel"]!,
                                imagePath:
                                    tag["imagePath"]!, // switched from imagePath → imagePath
                                rightText: tag["rightText"]!,
                                onTap: () {
                                  print("Tapped ${tag["categoryLabel"]}");
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 20),
                        Text(
                          "Top Social Circles",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        CommunityListHorizontal(), // <-- add it here
                      ],
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Select a Support tag and discover like contents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SocialTagHorizontal(
                          categoryLabel: "Emotional Healing",
                          imagePath:
                              "assets/icon/support-tags/emotionalHealing.svg",
                          rightText: "Emotional Healing",
                          iconShape: IconShape.square,
                          onTap: () {
                            print("Motivational clicked");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Anxiety & Stress",
                          imagePath:
                              "assets/icon/support-tags/anxietyAndStress.svg",
                          rightText: "Anxiety & Stress",
                          iconShape: IconShape.square,
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Grief & Heartbreak",
                          imagePath:
                              "assets/icon/support-tags/griefAndHeartbreak.svg",
                          rightText: "Grief & Heartbreak",
                          iconShape: IconShape.square,
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Work & Career",
                          imagePath:
                              "assets/icon/support-tags/workAndCareer.svg",
                          rightText: "Work & Career",
                          iconShape: IconShape.square,
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Trauma",
                          imagePath:
                              "assets/icon/support-tags/traumaAndHealing.svg",
                          rightText: "Trauma",
                          iconShape: IconShape.square,
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Family & Relations",
                          imagePath:
                              "assets/icon/support-tags/familyAndRelationship.svg",
                          rightText: "Family & Relations",
                          iconShape: IconShape.square,
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Self-Worth & Identity",
                          imagePath:
                              "assets/icon/support-tags/selfWorthAndIdentity.svg",
                          rightText: "Self-Worth & Identity",
                          iconShape: IconShape.square,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 20),
                        Text(
                          "Top Support Square by MHP's",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        CommunityListHorizontal(), // <-- add it here
                      ],
                    ),

                    const SizedBox(height: 20),
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
