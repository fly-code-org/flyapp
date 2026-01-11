import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/home/presentation/widgets/community_tabs.dart';
import 'package:fly/features/post/presentation/views/create_post_screen.dart';
import 'package:fly/features/post/presentation/controllers/post_controller.dart';
import 'package:fly/features/post/presentation/utils/post_converter.dart';
import 'package:fly/features/post/presentation/services/user_profile_service.dart';
import 'package:fly/features/home/presentation/widgets/social_feed.dart';
import 'package:fly/features/home/model/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int streakCount = 2;
  final int _currentIndex = 0;
  int activeTabIndex = 0;
  late final PostController _postController;

  // Keep posts in state so we can add new ones
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    // Get or create PostController
    if (Get.isRegistered<PostController>()) {
      _postController = Get.find<PostController>();
    } else {
      _postController = sl<PostController>();
      Get.put(_postController);
    }

    // Fetch posts when screen initializes (defer to prevent blocking during navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use scheduleMicrotask to defer execution but not wait too long
      Future.microtask(() {
        if (mounted) {
          _refreshPosts();
        }
      });
    });
  }

  Future<void> _refreshPosts() async {
    if (!mounted) return;

    try {
      // For now, fetch my posts. In the future, this should fetch posts
      // from all tags the user follows, or from specific tags based on the active tab
      await _postController.fetchMyPosts(forceRefresh: true);

      if (!mounted) return;

      // Convert API posts to UI posts (keep conversion simple and fast)
      if (!mounted) return;

      try {
        final apiPosts = _postController.posts.toList();
        
        // Extract unique author IDs from posts
        final authorIds = apiPosts.map((post) => post.authorId).toSet().toList();
        
        // Fetch user profiles for all authors
        final userProfileService = UserProfileService();
        final authorProfiles = await userProfileService.getUserProfiles(authorIds);
        
        // Build maps of authorProfileUrls and authorUsernames
        final authorProfileUrls = <String, String>{};
        final authorUsernames = <String, String>{};
        
        for (var entry in authorProfiles.entries) {
          final userId = entry.key;
          final profile = entry.value;
          
          final username = profile['username'];
          final picturePath = profile['picture_path'];
          
          if (username != null && username.isNotEmpty) {
            authorUsernames[userId] = username;
          }
          
          if (picturePath != null && picturePath.isNotEmpty) {
            authorProfileUrls[userId] = picturePath;
          }
        }
        
        // Convert posts with author information
        final uiPosts = PostConverter.toUIPosts(
          apiPosts,
          authorProfileUrls: authorProfileUrls,
          authorUsernames: authorUsernames,
        );

        // Update state directly - setState is async and won't block
        if (mounted) {
          setState(() {
            posts = uiPosts;
          });
        }
      } catch (e, stackTrace) {
        print('❌ [HOME] Error converting posts: $e');
        print('📚 [HOME] Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing posts: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [HOME] Error fetching posts: $e');
      print('📚 [HOME] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading posts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBottomNavBar() {
    // Use the user profile bottom navbar which routes correctly
    return BottomNavBar(currentIndex: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "🪽$streakCount Streaks",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/images/fly_home.svg",
                        height: 32,
                        semanticsLabel: 'Fly logo',
                      ),
                      GestureDetector(
                        onTap: () {},
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

                  // Tabs
                  SocialSupportTabs(
                    key: const ValueKey("tabs"),
                    onTabChanged: (index) {
                      setState(() {
                        activeTabIndex = index;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Feed
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Obx(() {
                        // Check loading state only when posts are empty (initial load)
                        final isLoading = _postController.isLoading.value;
                        final errorMessage = _postController.errorMessage.value;

                        if (isLoading && posts.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (posts.isEmpty && errorMessage.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.post_add,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first post!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (errorMessage.isNotEmpty && posts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshPosts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        // Use RepaintBoundary to optimize rebuilds
                        return RepaintBoundary(
                          child: RefreshIndicator(
                            onRefresh: _refreshPosts,
                            child: SocialFeed(
                              posts: posts,
                              isSocialTab: activeTabIndex == 0,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Button
            Positioned(
              bottom: 30,
              right: 16,
              child: Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () async {
                    // Use the proper CreatePostScreen from post feature
                    final postCreated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePostScreen(),
                      ),
                    );

                    // Refresh posts after creating a new post
                    // The CreatePostScreen returns true if post was created successfully
                    if (postCreated == true) {
                      // Small delay to ensure backend has processed the post
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (mounted) {
                        await _refreshPosts();
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
