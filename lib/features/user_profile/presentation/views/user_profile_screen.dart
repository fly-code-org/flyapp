import 'package:flutter/material.dart';
import 'package:fly/features/user_profile/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/user_profile/presentation/widgets/community_menu.dart';
import 'package:fly/features/user_profile/presentation/widgets/community_post_grid.dart';
import 'package:fly/features/user_profile/presentation/widgets/custom_tab_with_media.dart';
import 'package:fly/features/user_profile/presentation/widgets/profile_card.dart';
import 'package:fly/features/user_profile/presentation/widgets/user_info_card.dart';
import 'package:fly/features/user_profile/presentation/widgets/journal_grid_section.dart';
import 'package:get/get.dart';
import 'create_journal_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
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
        return const JournalGridSection();
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
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const CommunityMenuSheet(),
                );
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
                            userId: "Anonyamous",
                            bio:
                                "Exploring my journey toward mental well-being.",
                            location: "Chandigarh, India",
                            date: "March, 2025",
                          ),
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
                                    "My Journal",
                                    Icons.book_outlined,
                                    1,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildTabItem(
                                    "Bookmarks",
                                    Icons.bookmark_border_outlined,
                                    2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

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
                        imagePath: 'assets/images/mydp.JPG',
                        size: 120,
                        showEditIcon: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ✅ Add Journal FAB (visible only on My Journal tab)
          if (_selectedTab == 1)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF855DFC),
                onPressed: () => Get.to(() => const CreateJournalScreen()),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
