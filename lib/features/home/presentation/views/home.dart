import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/home/presentation/widgets/community_tabs.dart';

class HomeScreen extends StatelessWidget {
  final int streakCount = 2;
  final int _currentIndex = 0;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      body: SafeArea(
        child: Padding(
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
                  Image.asset(
                    "assets/images/fly_logo.png",
                    height: 32, // Adjust size as needed
                  ),

                  // Right: Upgrade text (clickable, route commented)
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

              const SizedBox(height: 24), // Spacing below top row
              // Tabs: Social & Support
              const SocialSupportTabs(),
            ],
          ),
        ),
      ),
    );
  }
}
