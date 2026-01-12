import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/features/user_profile/presentation/widgets/community_post_grid.dart';
import 'package:fly/features/user_profile/presentation/widgets/profile_card.dart';
import 'package:fly/features/user_profile/presentation/widgets/user_info_card.dart';
import 'package:fly/features/user_profile/presentation/widgets/journal_grid_section.dart';
import 'package:fly/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:fly/features/journal/presentation/controllers/journal_controller.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'create_journal_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late final UserProfileController _profileController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Get or create controller
    if (Get.isRegistered<UserProfileController>()) {
      _profileController = Get.find<UserProfileController>();
    } else {
      _profileController = sl<UserProfileController>();
      Get.put(_profileController, permanent: true);
    }
    
    // Always fetch profile to ensure we have latest data
    // The controller will handle caching internally
    print('🔍 [PROFILE SCREEN] Initializing, fetching user profile...');
    _profileController.fetchUserProfile(forceRefresh: false);
    
    // Initialize and prefetch journal data (color templates + journals)
    // This ensures data is ready when user clicks on "My Journal" tab
    _initializeJournalData();
  }

  void _initializeJournalData() {
    // Get or create journal controller
    JournalController journalController;
    if (Get.isRegistered<JournalController>()) {
      journalController = Get.find<JournalController>();
    } else {
      journalController = sl<JournalController>();
      Get.put(journalController, permanent: true);
    }
    
    // IMPORTANT: Fetch color templates FIRST (needed for journal creation and color mapping)
    // This ensures templates are available when user creates a journal
    journalController.fetchColorTemplates().then((_) {
      print('✅ [PROFILE] Color templates loaded (${journalController.colorTemplates.length} templates), prefetching journals...');
      // Prefetch journals so they're ready when user clicks the tab
      if (journalController.journals.isEmpty && !journalController.isLoading.value) {
        journalController.fetchJournals();
      }
    }).catchError((e) {
      print('⚠️ [PROFILE] Error loading color templates: $e');
      // Still try to fetch journals even if color templates fail
      // But warn that journal creation might fail
      print('⚠️ [PROFILE] Journal creation may fail without color templates');
      if (journalController.journals.isEmpty && !journalController.isLoading.value) {
        journalController.fetchJournals();
      }
    });
  }

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
        return Obx(() {
          final activities = _profileController.activities.toList();
          // Use a key based on activities length to force widget recreation when data changes
          return CommunityMediaSection(
            key: ValueKey('activities_${activities.length}_${activities.join(',')}'),
            type: "Activities",
            postIds: activities,
          );
        });
      case 1:
        // Journal data should already be prefetched in initState
        // But if for some reason it's not loaded, fetch it now
        if (Get.isRegistered<JournalController>()) {
          final journalController = Get.find<JournalController>();
          // Only fetch if not already loading and journals are empty
          if (journalController.journals.isEmpty && 
              !journalController.isLoading.value &&
              journalController.colorTemplates.isEmpty) {
            // If color templates are also empty, fetch both
            journalController.fetchColorTemplates().then((_) {
              journalController.fetchJournals();
            });
          } else if (journalController.journals.isEmpty && 
                     !journalController.isLoading.value) {
            // Just fetch journals if color templates are already loaded
            journalController.fetchJournals();
          }
        }
        return const JournalGridSection();
      case 2:
        return Obx(() {
          final bookmarkedPosts = _profileController.bookmarkedPosts.toList();
          // Use a key based on bookmarks length to force widget recreation when data changes
          final bookmarksKey = bookmarkedPosts.map((b) => b['post_id'] as String? ?? '').join(',');
          return CommunityMediaSection(
            key: ValueKey('bookmarks_${bookmarkedPosts.length}_$bookmarksKey'),
            type: "Bookmarks",
            bookmarkedPosts: bookmarkedPosts,
          );
        });
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
                      child: Obx(() {
                        // Show loading indicator
                        if (_profileController.isLoading.value &&
                            _profileController.profileData.value == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Show error message
                        if (_profileController.errorMessage.value.isNotEmpty &&
                            _profileController.profileData.value == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Error loading profile',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _profileController.errorMessage.value,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      _profileController.fetchUserProfile(
                                          forceRefresh: true);
                                    },
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show profile data with fixed header and scrollable content
                        return Column(
                          children: [
                            // Fixed Header Section (Avatar, UserInfo, Tabs)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const SizedBox(height: 60),
                                  Obx(() => UserInfo(
                                    userId: _profileController.username.value.isEmpty
                                        ? "Anonymous"
                                        : _profileController.username.value,
                                    bio: _profileController.bio.value.isEmpty
                                        ? "No bio yet."
                                        : _profileController.bio.value,
                                    location: _profileController.location.value,
                                    date: _profileController.createdAt.value,
                                  )),
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
                                ],
                              ),
                            ),
                            // Scrollable Content Section (Only tab content)
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildBody(),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    // Floating avatar
                    Positioned(
                      top: -60,
                      left: 16,
                      child: Obx(() {
                        // Extract user ID from profile data for avatar generation
                        final userId = _profileController.profileData.value?['user_id'] as String?;
                        // Pass picturePath directly - ProfileAvatar will handle asset paths vs URLs
                        final picturePath = _profileController.picturePath.value;
                        print('🖼️ [PROFILE SCREEN] picturePath: "$picturePath", userId: "$userId"');
                        return ProfileAvatar(
                            imagePath: picturePath, // ProfileAvatar handles both assets and URLs
                            userId: userId,
                            size: 120,
                            showEditIcon: false,
                          );
                      }),
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
                onPressed: () async {
                  final result = await Get.to(() => const CreateJournalScreen());
                  // Refresh journals if journal was created
                  if (result == true) {
                    if (Get.isRegistered<JournalController>()) {
                      final journalController = Get.find<JournalController>();
                      journalController.fetchJournals(forceRefresh: true);
                    }
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
