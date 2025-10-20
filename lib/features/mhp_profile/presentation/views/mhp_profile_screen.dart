import 'package:flutter/material.dart';
import 'package:fly/features/create_community/presentation/widgets/edit_community_button.dart';
import 'package:fly/features/create_community/presentation/widgets/invite_members.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/community_post_grid.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/edit_profile_button.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_squares.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/share_profile.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/profile_card.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_info_card.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/about_screen.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MhpProfileScreen extends StatefulWidget {
  const MhpProfileScreen({super.key});

  @override
  State<MhpProfileScreen> createState() => _MhpProfileScreenState();
}

class _MhpProfileScreenState extends State<MhpProfileScreen>
    with SingleTickerProviderStateMixin {
  late final String role;
  int _selectedTab = 0;

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? Color(0xFF855DFC) : Colors.grey),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Color(0xFF855DFC) : Colors.grey[700],
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: isActive ? Color(0xFF855DFC) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return const CommunityMediaSection(type: "Activities");
      case 1:
        return const MHPProfileEditScreen();
      case 2:
        return const CommunityMediaSection(type: "Bookmarks");
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Bottom nav bar
      bottomNavigationBar: BottomNavBar(currentIndex: 4),

      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),

          // Settings (hamburger menu)
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(
                Icons.settings_suggest_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.UserSettingsScreen);
              },
            ),
          ),

          // Draggable white sheet
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // setState(() {
                  //   _dragPosition = notification.extent;
                  // });
                  return true;
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // White sheet
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          const SizedBox(height: 60),
                          const UserInfo(
                            userName: "Shruti Jain",
                            bio:
                                "Helping you navigate anxiety, trauma, and self-growth with empathy & evidence-based therapy.",
                            location: "Chandigarh, India",
                            yearsOfExp: "March, 2025",
                          ),
                          const SizedBox(height: 20),

                          // Edit + Invite Members
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              EditProfileButton(
                                onPressed: () {
                                  Get.toNamed('/edit-community');
                                },
                              ),
                              const SizedBox(width: 20),
                              ShareProfile(
                                onPressed: () {
                                  Get.toNamed('/invite-members');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          MHPSquare(),
                          const SizedBox(height: 40),
                          // Tabs Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTabItem(
                                "Activities",
                                Icons.dashboard_outlined,
                                0,
                              ),
                              Row(
                                children: [
                                  _buildTabItem(
                                    "About",
                                    Icons.verified_user_outlined,
                                    1,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildTabItem(
                                    "Connect",
                                    Icons.calendar_month_outlined,
                                    2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Tab content
                          SizedBox(height: 600, child: _buildBody()),
                        ],
                      ),
                    ),

                    // Floating avatar
                    Positioned(
                      top: -60,
                      left: 16,
                      child: const ProfileAvatar(
                        imagePath: 'assets/images/communitydp.png',
                        size: 120,
                        showEditIcon: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
