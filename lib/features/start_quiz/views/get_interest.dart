import 'package:flutter/material.dart';
import 'package:fly/features/start_quiz/widgets/communities_grid.dart';
import 'package:fly/features/start_quiz/widgets/separator.dart';
import 'package:fly/features/start_quiz/widgets/social_tags.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class GetInterestScreen extends StatefulWidget {
  const GetInterestScreen({super.key});

  @override
  State<GetInterestScreen> createState() => _GetInterestScreenState();
}

class _GetInterestScreenState extends State<GetInterestScreen> {
  double _dragPosition = 0.8;
  late final String role;

  final sampleCommunities = [
    {
      'profilePicUrl': 'https://cdn.flyapp.in/assets/community-demo.png',
      'communityName': 'Mindfulness Group',
      'communityId': 'mindfulness_123',
      'followerCount': 1500,
    },
    {
      'profilePicUrl': 'https://cdn.flyapp.in/assets/community-demo.png',
      'communityName': 'Anxiety Support',
      'communityId': 'anxiety_456',
      'followerCount': 2300,
    },
    {
      'profilePicUrl': 'https://cdn.flyapp.in/assets/community-demo.png',
      'communityName': 'Mindfulness Group',
      'communityId': 'mindfulness_789',
      'followerCount': 1500,
    },
    {
      'profilePicUrl': 'https://cdn.flyapp.in/assets/community-demo.png',
      'communityName': 'Anxiety Support',
      'communityId': 'anxiety_987',
      'followerCount': 2300,
    },
    // add more...
  ];

  // Track which button text to show
  bool _showSureLetsGo = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
    print("PhoneVerification role: $role");
  }

  void _handleButtonPressed() {
    if (_showSureLetsGo) {
      // Navigate with "Sure, let's go"
      Get.toNamed('/intro-quiz', arguments: {'text': "Sure, let's go"});
      setState(() {
        _showSureLetsGo = false; // Switch text on next render
      });
    } else {
      // Navigate with "Next >>>>"
      Get.toNamed('/intro-quiz', arguments: {'text': "Next >>>>"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _dragPosition > 0.3
                ? 50
                : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: 100,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _dragPosition = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Text(
                        "Which tags would you like to follow?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Separator(),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SocialTag(
                            categoryLabel: "Motivational",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/motivational.svg",
                            rightText: "Motivational",
                            onTap: () {
                              print("Motivational clicked");
                            },
                          ),
                          SocialTag(
                            categoryLabel: "Lifestyle",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/lifestyle.svg",
                            rightText: "Lifestyle",
                          ),
                          SocialTag(
                            categoryLabel: "Art & Creatives",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/artAndCreativity.svg",
                            rightText: "Art & Creatives",
                          ),
                          SocialTag(
                            categoryLabel: "Awwdorable",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/awdorable.svg",
                            rightText: "Awwdorable",
                          ),
                          SocialTag(
                            categoryLabel: "Fun & Humor",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/funAndHumor.svg",
                            rightText: "Fun & Humor",
                          ),
                          SocialTag(
                            categoryLabel: "Peace",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/peace.svg",
                            rightText: "Peace",
                          ),
                          SocialTag(
                            categoryLabel: "Words of Wisdom",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/wordsOfWisdom.svg",
                            rightText: "Words of Wisdom",
                          ),
                          SocialTag(
                            categoryLabel: "News & Insights",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/newsAndInsights.svg",
                            rightText: "News & Insights",
                          ),
                          SocialTag(
                            categoryLabel: "Movies & Shows",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/moviesAndShows.svg",
                            rightText: "Movies & Shows",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Separator(text: "Support tags"),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SocialTag(
                            categoryLabel: "Emotional Healing",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/emotionalHealing.svg",
                            rightText: "Emotional Healing",
                            iconShape: IconShape.square,
                            onTap: () {
                              print("Motivational clicked");
                            },
                          ),
                          SocialTag(
                            categoryLabel: "Anxiety & Stress",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/anxietyAndStress.svg",
                            rightText: "Anxiety & Stress",
                            iconShape: IconShape.square,
                          ),
                          SocialTag(
                            categoryLabel: "Grief & Heartbreak",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/griefAndHeartbreak.svg",
                            rightText: "Grief & Heartbreak",
                            iconShape: IconShape.square,
                          ),
                          SocialTag(
                            categoryLabel: "Work & Career",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/workAndCareer.svg",
                            rightText: "Work & Career",
                            iconShape: IconShape.square,
                          ),
                          SocialTag(
                            categoryLabel: "Trauma",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/traumaAndHealing.svg",
                            rightText: "Trauma",
                            iconShape: IconShape.square,
                          ),
                          SocialTag(
                            categoryLabel: "Family & Relations",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/familyAndRelationship.svg",
                            rightText: "Family & Relations",
                            iconShape: IconShape.square,
                          ),
                          SocialTag(
                            categoryLabel: "Self-Worth & Identity",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/selfWorthAndIdentity.svg",
                            rightText: "Self-Worth & Identity",
                            iconShape: IconShape.square,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Separator(text: "Communities by MHPs✨"),
                      const SizedBox(height: 20),
                      CommunitiesGrid(communities: sampleCommunities),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: "Explore fly!",
                        onPressed: () {
                          Get.toNamed(AppRoutes.Explore);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
