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
import 'package:fly/features/user_profile/presentation/controllers/user_profile_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  int activeTabIndex = 0;
  late final PostController _postController;
  late final UserProfileController _profileController;
  final ScrollController _scrollController = ScrollController();

  // Posts per tab: Social (0) vs Support (1)
  List<Post> socialPosts = [];
  List<Post> supportPosts = [];

  // Pagination: only when using feed (fetchMyPosts has no pagination)
  bool _isUsingFeed = false;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;

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

    // Get or create UserProfileController
    if (Get.isRegistered<UserProfileController>()) {
      _profileController = Get.find<UserProfileController>();
    } else {
      _profileController = sl<UserProfileController>();
      Get.put(_profileController, permanent: true);
    }

    // Fetch user profile to get streak count
    _profileController.fetchUserProfile(forceRefresh: false);

    // Fetch posts for both tabs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (mounted) _refreshBothTabs();
      });
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasReachedEnd || _isLoadingMore || !_isUsingFeed) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  List<Post> get _currentPosts =>
      activeTabIndex == 0 ? socialPosts : supportPosts;

  /// Fetches and populates both Social and Support tabs
  Future<void> _refreshBothTabs() async {
    if (!mounted) return;
    _postController.clearError();
    _hasReachedEnd = false;
    _isUsingFeed = true;

    try {
      // Sequential to avoid PostController.posts race (shared state)
      await _fetchAndSetTabPosts('social', 0);
      if (!mounted) return;
      await _fetchAndSetTabPosts('support', 1);
    } catch (e) {
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

  Future<void> _fetchAndSetTabPosts(String typeFilter, int tabIndex) async {
    await _postController.fetchFeed(
      limit: 20,
      offset: 0,
      typeFilter: typeFilter,
      forceRefresh: true,
    );
    if (!mounted) return;

    final rawPosts = _postController.posts.toList();
    // When tag_type is present, filter by it; otherwise trust backend filter
    final apiPosts = rawPosts
        .where((p) => p.tagType == null || p.tagType == typeFilter)
        .toList();
    final authorIds = apiPosts.map((p) => p.authorId).toSet().toList();

    final userProfileService = UserProfileService();
    final authorProfiles = await userProfileService.getUserProfiles(authorIds);

    final authorProfileUrls = <String, String>{};
    final authorUsernames = <String, String>{};

    for (var entry in authorProfiles.entries) {
      final userId = entry.key;
      final profile = entry.value;
      final usernameValue = profile['username'];
      if (usernameValue != null) {
        final s = usernameValue.toString().trim();
        if (s.isNotEmpty) authorUsernames[userId] = s;
      }
      final picPath = profile['picture_path'] ?? profile['picturePath'];
      if (picPath != null) {
        final p = picPath.toString().trim();
        if (p.isNotEmpty) authorProfileUrls[userId] = p;
      }
    }

    final uiPosts = PostConverter.toUIPosts(
      apiPosts,
      authorProfileUrls: authorProfileUrls,
      authorUsernames: authorUsernames,
    );

    if (mounted) {
      setState(() {
        if (tabIndex == 0) {
          socialPosts = uiPosts;
        } else {
          supportPosts = uiPosts;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh posts when screen becomes visible again (e.g., navigating back from explore)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _currentPosts.isEmpty &&
          !_postController.isLoading.value) {
        Future.microtask(() {
          if (mounted) _refreshPosts();
        });
      }
    });
  }

  Future<void> _refreshPosts() async {
    if (!mounted) return;

    _postController.clearError();
    _hasReachedEnd = false;

    try {
      final typeFilter = activeTabIndex == 0 ? 'social' : 'support';
      await _postController.fetchFeed(
        limit: 20,
        offset: 0,
        typeFilter: typeFilter,
        forceRefresh: true,
      );
      _isUsingFeed = true;

      if (!mounted) return;

      final rawPosts = _postController.posts.toList();
      // When tag_type is present, filter by it; otherwise trust backend filter
      final apiPosts = rawPosts
          .where((p) => p.tagType == null || p.tagType == typeFilter)
          .toList();
      final authorIds = apiPosts.map((p) => p.authorId).toSet().toList();

      final userProfileService = UserProfileService();
      final authorProfiles = await userProfileService.getUserProfiles(
        authorIds,
      );

      final authorProfileUrls = <String, String>{};
      final authorUsernames = <String, String>{};

      for (var entry in authorProfiles.entries) {
        final userId = entry.key;
        final profile = entry.value;
        final usernameValue = profile['username'];
        if (usernameValue != null) {
          final s = usernameValue.toString().trim();
          if (s.isNotEmpty) authorUsernames[userId] = s;
        }
        final picPath = profile['picture_path'] ?? profile['picturePath'];
        if (picPath != null) {
          final p = picPath.toString().trim();
          if (p.isNotEmpty) authorProfileUrls[userId] = p;
        }
      }

      final uiPosts = PostConverter.toUIPosts(
        apiPosts,
        authorProfileUrls: authorProfileUrls,
        authorUsernames: authorUsernames,
      );

      if (mounted) {
        setState(() {
          if (activeTabIndex == 0) {
            socialPosts = uiPosts;
          } else {
            supportPosts = uiPosts;
          }
        });
      }
    } catch (e) {
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

  Future<void> _loadMorePosts() async {
    if (!mounted || _isLoadingMore || _hasReachedEnd || !_isUsingFeed) return;
    if (_postController.isLoading.value) return;

    setState(() => _isLoadingMore = true);

    try {
      final typeFilter = activeTabIndex == 0 ? 'social' : 'support';
      final currentLen = _currentPosts.length;
      await _postController.fetchFeed(
        limit: 20,
        offset: currentLen,
        typeFilter: typeFilter,
        forceRefresh: true,
      );

      if (!mounted) return;

      final rawNewPosts = _postController.posts.toList();
      final newApiPosts = rawNewPosts
          .where((p) => p.tagType == null || p.tagType == typeFilter)
          .toList();
      if (newApiPosts.isEmpty) {
        _hasReachedEnd = true;
        _isLoadingMore = false;
        return;
      }

      if (newApiPosts.length < 20) {
        _hasReachedEnd = true;
      }

      final authorIds = newApiPosts.map((p) => p.authorId).toSet().toList();
      final userProfileService = UserProfileService();
      final authorProfiles = await userProfileService.getUserProfiles(
        authorIds,
      );

      final authorProfileUrls = <String, String>{};
      final authorUsernames = <String, String>{};

      for (var entry in authorProfiles.entries) {
        final userId = entry.key;
        final profile = entry.value;
        final usernameValue = profile['username'];
        if (usernameValue != null) {
          final s = usernameValue.toString().trim();
          if (s.isNotEmpty) authorUsernames[userId] = s;
        }
        final picPath = profile['picture_path'] ?? profile['picturePath'];
        if (picPath != null) {
          final p = picPath.toString().trim();
          if (p.isNotEmpty) authorProfileUrls[userId] = p;
        }
      }

      final newUiPosts = PostConverter.toUIPosts(
        newApiPosts,
        authorProfileUrls: authorProfileUrls,
        authorUsernames: authorUsernames,
      );

      final currentList = activeTabIndex == 0 ? socialPosts : supportPosts;
      final existingIds = currentList.map((p) => p.id).toSet();
      final toAppend = newUiPosts
          .where((p) => !existingIds.contains(p.id))
          .toList();

      if (mounted && toAppend.isNotEmpty) {
        setState(() {
          if (activeTabIndex == 0) {
            socialPosts = [...socialPosts, ...toAppend];
          } else {
            supportPosts = [...supportPosts, ...toAppend];
          }
        });
      }
    } catch (_) {
      // Silently ignore load-more errors
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
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
                          child: Obx(
                            () => Text(
                              "🪽${_profileController.streakCount.value} Streaks",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
                      // If switching to a tab with no posts and using feed, fetch for that tab
                      if (_isUsingFeed &&
                          (index == 0 ? socialPosts : supportPosts).isEmpty &&
                          !_postController.isLoading.value) {
                        Future.microtask(() {
                          if (mounted) _refreshPosts();
                        });
                      }
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

                        if (isLoading && _currentPosts.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_currentPosts.isEmpty && errorMessage.isEmpty) {
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

                        if (errorMessage.isNotEmpty && _currentPosts.isEmpty) {
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Clear error and retry
                                    _postController.clearError();
                                    _refreshPosts();
                                  },
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
                              posts: _currentPosts,
                              isSocialTab: activeTabIndex == 0,
                              scrollController: _scrollController,
                              isLoadingMore: _isLoadingMore,
                              onPostUpdated: (updatedPost) {
                                setState(() {
                                  final list = activeTabIndex == 0
                                      ? socialPosts
                                      : supportPosts;
                                  final index = list.indexWhere(
                                    (p) => p.id == updatedPost.id,
                                  );
                                  if (index != -1) {
                                    if (activeTabIndex == 0) {
                                      socialPosts = [...socialPosts];
                                      socialPosts[index] = updatedPost;
                                    } else {
                                      supportPosts = [...supportPosts];
                                      supportPosts[index] = updatedPost;
                                    }
                                  }
                                });
                              },
                              onRefreshNeeded: () {
                                // Refresh posts from server to get actual like counts
                                _refreshPosts();
                              },
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
