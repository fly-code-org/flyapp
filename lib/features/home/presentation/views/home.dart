import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/home/presentation/widgets/community_tabs.dart';
import 'package:fly/features/home/presentation/widgets/social_feed.dart'; // Import SocialFeed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int streakCount = 2;
  final int _currentIndex = 0;
  int activeTabIndex = 0; // 0 -> Social, 1 -> Support

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Streak, Fly Logo, Upgrade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Streak pill with dashed border
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          strokeWidth: 1.5,
                          dashPattern: const [6, 3],
                          color: Colors.grey,
                          radius: const Radius.circular(30),
                          padding: EdgeInsets.zero,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "🪽$streakCount Streaks",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Center: Fly logo
                      Image.asset("assets/images/fly_logo.png", height: 32),

                      // Right: Upgrade text (clickable)
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(context,
                          //   MaterialPageRoute(builder: (_) => UpgradeScreen()));
                        },
                        child: const Text(
                          "Upgrade",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tabs: Social & Support
                  SocialSupportTabs(
                    key: const ValueKey("tabs"),
                    onTabChanged: (index) {
                      setState(() {
                        activeTabIndex = index;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Expanded SocialFeed
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: SocialFeed(isSocialTab: activeTabIndex == 0),
                    ),
                  ),
                ],
              ),
            ),

            // Pill-shaped Create Post button
            Positioned(
              bottom: 30,
              right: 16,
              child: Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to Create Post screen
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Create Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
