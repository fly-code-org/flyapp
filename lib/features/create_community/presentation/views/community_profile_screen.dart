import 'package:flutter/material.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/create_community/presentation/widgets/community_menu.dart';
import 'package:fly/features/create_community/presentation/widgets/community_post_grid.dart';
import 'package:fly/features/create_community/presentation/widgets/community_profile_card.dart';
import 'package:fly/features/create_community/presentation/widgets/custom_tab_with_media.dart';
import 'package:fly/features/create_community/presentation/widgets/edit_community_button.dart';
import 'package:fly/features/create_community/presentation/widgets/invite_members.dart';
import 'package:get/get.dart';

class CommunitySupportProfile extends StatefulWidget {
  const CommunitySupportProfile({super.key});

  @override
  State<CommunitySupportProfile> createState() =>
      _CommunitySupportProfileState();
}

class _CommunitySupportProfileState extends State<CommunitySupportProfile> {
  double _dragPosition = 0.9;
  late final String role;

  int _currentIndex = 0;
  TabController? _tabController; // <-- to pass into posts grid

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Bottom nav bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              print("Go to Home");
              break;
            case 1:
              print("Go to Explore");
              break;
            case 3:
              print("Go to Notifications");
              break;
            case 4:
              print("Go to Profile");
              break;
          }
        },
      ),

      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          // Hamburger menu
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
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

          // Draggable sheet
          DraggableScrollableSheet(
            initialChildSize: 0.87,
            minChildSize: 0.87,
            maxChildSize: 0.87,
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
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: DefaultTabController(
                    length: 2, // Number of tabs: "New" & "Popular"
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 15),

                        // Community profile card
                        CommunityProfileCard(
                          communityType: "support",
                          title: "Mental Wellness Hub",
                          members: 1540,
                          profileImagePath: "assets/images/community1.png",
                          tagIconPath:
                              "assets/icon/social-tags/wordsOfWisdom.svg",
                          description:
                              "A safe space to discuss mental health, share resources, and support each other on our wellness journeys.",
                        ),

                        const SizedBox(height: 20),

                        // Edit + Invite Members
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            EditCommunityButton(
                              onPressed: () {
                                Get.toNamed('/edit-community');
                              },
                            ),
                            const SizedBox(width: 35),
                            InviteMembersButton(
                              onPressed: () {
                                Get.toNamed('/invite-members');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Tabs with Media button
                        CustomTabWithMedia(
                          onMediaPressed: () {
                            print("Media button clicked!");
                          },
                        ),

                        const SizedBox(height: 20),

                        // Tab content (grid of posts)
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            children: const [
                              CommunityMediaSection(type: "new"),
                              CommunityMediaSection(type: "popular"),
                            ],
                          ),
                        ),
                      ],
                    ),
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
