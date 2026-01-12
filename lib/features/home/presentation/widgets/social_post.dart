import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/core/widgets/safe_svg_icon.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:fly/features/post/presentation/controllers/post_controller.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:fly/features/post/presentation/widgets/comment_bottom_sheet.dart';

class SocialPost extends StatefulWidget {
  final Post post;
  final bool isSocialTab;
  final Function(Post)? onPostUpdated;
  final VoidCallback? onRefreshNeeded;

  const SocialPost({
    super.key,
    required this.post,
    this.isSocialTab = true,
    this.onPostUpdated,
    this.onRefreshNeeded,
  });

  @override
  _SocialPostState createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  VideoPlayerController? _videoController;
  PageController? _pageController;
  late bool isLiked;
  late bool isBookmarked;
  bool isTextExpanded = false;
  int _currentPage = 0;
  bool _isLiking = false;
  bool _isBookmarking = false;
  late PostController _postController;
  UserProfileController? _userProfileController;

  @override
  void initState() {
    super.initState();

    // Check if current user has already liked this post
    isLiked = _checkIfUserLikedPost();

    // Check if current user has already bookmarked this post
    isBookmarked = _checkIfUserBookmarkedPost();

    // Get PostController
    if (Get.isRegistered<PostController>()) {
      _postController = Get.find<PostController>();
    } else {
      _postController = sl<PostController>();
      Get.put(_postController);
    }

    // Get UserProfileController to check bookmarked posts
    if (Get.isRegistered<UserProfileController>()) {
      _userProfileController = Get.find<UserProfileController>();
    } else {
      _userProfileController = sl<UserProfileController>();
      Get.put(_userProfileController, permanent: true);
    }

    // Only create PageController if there are multiple images
    if (widget.post.mediaUrls != null && widget.post.mediaUrls!.length > 1) {
      _pageController = PageController();
    }

    if (widget.post.isVideo && !kIsWeb && widget.post.mediaUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.post.mediaUrl!),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            )
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {});
                    _videoController?.setLooping(true);
                    _videoController?.setVolume(0);
                    _videoController?.play();
                  }
                })
                .catchError((error) {
                  print('❌ [SOCIAL POST] Error initializing video: $error');
                  if (mounted) {
                    setState(() {});
                  }
                });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  /// Checks if the current user has already liked this post
  bool _checkIfUserLikedPost() {
    try {
      final token = ApiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final currentUserId = JwtDecoder.getUserId(token);
      if (currentUserId == null || currentUserId.isEmpty) {
        return false;
      }

      // Check if current user ID is in the likedBy list
      final likedBy = widget.post.likedBy;
      if (likedBy == null || likedBy.isEmpty) {
        return false;
      }

      return likedBy.contains(currentUserId);
    } catch (e) {
      print('⚠️ [SOCIAL POST] Error checking if user liked post: $e');
      return false;
    }
  }

  bool _checkIfUserBookmarkedPost() {
    try {
      // Check if post ID exists in user's bookmarked_posts array from user_profile collection
      if (_userProfileController == null) {
        print('⚠️ [SOCIAL POST] UserProfileController not available');
        return false;
      }

      final bookmarkedPosts = _userProfileController!.bookmarkedPosts;
      if (bookmarkedPosts.isEmpty) {
        return false;
      }

      // Check if current post ID is in the user's bookmarked posts list
      // Each bookmark in bookmarkedPosts is a Map with 'post_id' key
      for (var bookmark in bookmarkedPosts) {
        final postId = bookmark['post_id'] as String?;
        if (postId != null && postId == widget.post.id) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('⚠️ [SOCIAL POST] Error checking if user bookmarked post: $e');
      return false;
    }
  }

  Future<void> _handleLikeToggle() async {
    // Prevent multiple simultaneous like operations (check synchronously)
    if (_isLiking) {
      print(
        '⚠️ [SOCIAL POST] Like operation already in progress, ignoring click',
      );
      return;
    }

    // Set flag immediately to prevent multiple clicks (before any async operations)
    _isLiking = true;

    // Store the current like state
    final wasLiked = isLiked;

    // Get current user ID
    String? currentUserId;
    try {
      final token = ApiClient.getAuthToken();
      if (token != null && token.isNotEmpty) {
        currentUserId = JwtDecoder.getUserId(token);
      }
    } catch (e) {
      print('⚠️ [SOCIAL POST] Error getting current user ID: $e');
      _isLiking = false;
      return;
    }

    if (currentUserId == null || currentUserId.isEmpty) {
      print(
        '⚠️ [SOCIAL POST] Current user ID not available, cannot like/unlike',
      );
      _isLiking = false;
      return;
    }

    // Prevent duplicate likes - if trying to like and already in likedBy list, prevent it
    final likedBy = widget.post.likedBy ?? [];
    if (!wasLiked && likedBy.contains(currentUserId)) {
      print(
        '⚠️ [SOCIAL POST] User has already liked this post, preventing duplicate like',
      );
      _isLiking = false;
      // Update UI state to reflect that it's already liked
      if (mounted) {
        setState(() {
          isLiked = true;
        });
      }
      return;
    }

    // Prevent unliking if user hasn't liked it
    if (wasLiked && !likedBy.contains(currentUserId)) {
      print('⚠️ [SOCIAL POST] User has not liked this post, preventing unlike');
      _isLiking = false;
      // Update UI state to reflect that it's not liked
      if (mounted) {
        setState(() {
          isLiked = false;
        });
      }
      return;
    }

    // Update UI state optimistically (just the heart icon, not the count)
    // This will trigger the animation
    if (mounted) {
      setState(() {
        isLiked = !isLiked;
      });
    }

    try {
      bool success;
      if (!wasLiked) {
        // User is liking the post
        print('❤️ [SOCIAL POST] Attempting to like post: ${widget.post.id}');
        success = await _postController.likePostEntry(widget.post.id);
      } else {
        // User is unliking the post
        print('💔 [SOCIAL POST] Attempting to unlike post: ${widget.post.id}');
        success = await _postController.unlikePostEntry(widget.post.id);
      }

      if (success) {
        print('✅ [SOCIAL POST] Like/unlike API call succeeded');
        // API call succeeded - refresh posts from server to get actual like count from database
        // This ensures we have the correct count and likedBy list from the database
        if (widget.onRefreshNeeded != null) {
          widget.onRefreshNeeded!();
        }
      } else {
        print('❌ [SOCIAL POST] Like/unlike API call failed, reverting');
        // Revert the optimistic update if API call failed
        if (mounted) {
          setState(() {
            isLiked = wasLiked;
          });
        }
      }
    } catch (e, stackTrace) {
      print('❌ [SOCIAL POST] Error toggling like: $e');
      print('📚 [SOCIAL POST] Stack trace: $stackTrace');
      // Revert the like state on error
      if (mounted) {
        setState(() {
          isLiked = wasLiked;
        });
      }
    } finally {
      _isLiking = false;
    }
  }

  Future<void> _handleBookmarkToggle() async {
    // Prevent multiple simultaneous bookmark operations (check synchronously)
    if (_isBookmarking) {
      print(
        '⚠️ [SOCIAL POST] Bookmark operation already in progress, ignoring click',
      );
      return;
    }

    // Set flag immediately to prevent multiple clicks (before any async operations)
    _isBookmarking = true;

    // Store the current bookmark state
    final wasBookmarked = isBookmarked;

    // Get current user ID
    String? currentUserId;
    try {
      final token = ApiClient.getAuthToken();
      if (token != null && token.isNotEmpty) {
        currentUserId = JwtDecoder.getUserId(token);
      }
    } catch (e) {
      print('⚠️ [SOCIAL POST] Error getting current user ID: $e');
      _isBookmarking = false;
      return;
    }

    if (currentUserId == null || currentUserId.isEmpty) {
      print(
        '⚠️ [SOCIAL POST] Current user ID not available, cannot bookmark/unbookmark',
      );
      _isBookmarking = false;
      return;
    }

    // Prevent duplicate bookmarks - check if post is already in user's bookmarked_posts
    final isCurrentlyBookmarked = _checkIfUserBookmarkedPost();
    if (!wasBookmarked && isCurrentlyBookmarked) {
      print(
        '⚠️ [SOCIAL POST] Post already bookmarked by current user, preventing duplicate bookmark',
      );
      _isBookmarking = false;
      // Update UI state to reflect that it's already bookmarked
      if (mounted) {
        setState(() {
          isBookmarked = true;
        });
      }
      return;
    }

    // Prevent duplicate unbookmarks - check if post is not in user's bookmarked_posts
    if (wasBookmarked && !isCurrentlyBookmarked) {
      print(
        '⚠️ [SOCIAL POST] Post not bookmarked by current user, preventing duplicate unbookmark',
      );
      _isBookmarking = false;
      // Update UI state to reflect that it's not bookmarked
      if (mounted) {
        setState(() {
          isBookmarked = false;
        });
      }
      return;
    }

    // Optimistic UI update
    if (mounted) {
      setState(() {
        isBookmarked = !isBookmarked;
      });
    }

    try {
      bool success;
      if (!wasBookmarked) {
        // User is bookmarking the post
        print(
          '🔖 [SOCIAL POST] Attempting to bookmark post: ${widget.post.id}',
        );
        success = await _postController.bookmarkPostEntry(widget.post.id);
      } else {
        // User is unbookmarking the post
        print(
          '🔓 [SOCIAL POST] Attempting to unbookmark post: ${widget.post.id}',
        );
        success = await _postController.unbookmarkPostEntry(widget.post.id);
      }

      if (success) {
        print('✅ [SOCIAL POST] Bookmark/unbookmark API call succeeded');
        // Refresh user profile to get updated bookmarked_posts list from database
        if (_userProfileController != null) {
          await _userProfileController!.fetchUserProfile(forceRefresh: true);
          // Update bookmark state based on updated profile
          if (mounted) {
            setState(() {
              isBookmarked = _checkIfUserBookmarkedPost();
            });
          }
        }
        // Also refresh posts from server to get actual bookmark count from database
        if (widget.onRefreshNeeded != null) {
          widget.onRefreshNeeded!();
        }
      } else {
        print('❌ [SOCIAL POST] Bookmark/unbookmark API call failed, reverting');
        // API call failed - revert optimistic UI update
        if (mounted) {
          setState(() {
            isBookmarked = wasBookmarked;
          });
        }
      }
    } catch (e, stackTrace) {
      print('❌ [SOCIAL POST] Error toggling bookmark: $e');
      print('📚 [SOCIAL POST] Stack trace: $stackTrace');
      // Error occurred - revert optimistic UI update
      if (mounted) {
        setState(() {
          isBookmarked = wasBookmarked;
        });
      }
    } finally {
      _isBookmarking = false;
    }
  }

  Widget _buildProfilePicture() {
    final profileUrl = widget.post.profileUrl;

    // Check if this is a local asset path
    final isLocalAsset = ProfilePictureHelper.isLocalAsset(profileUrl);

    Widget profileWidget;

    if (isLocalAsset) {
      // Handle local asset profile pictures (e.g., /assets/profile_2.svg)
      final assetPath = ProfilePictureHelper.getAssetPath(profileUrl);
      final isSvg = assetPath.toLowerCase().endsWith('.svg');

      if (isSvg) {
        profileWidget = SvgPicture.asset(
          assetPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
              '⚠️ [SOCIAL POST] Error loading SVG profile picture from assets: $assetPath - $error',
            );
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          semanticsLabel: 'Profile picture',
        );
      } else {
        // Handle regular image from assets
        profileWidget = Image.asset(
          assetPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print(
              '⚠️ [SOCIAL POST] Error loading profile image from assets: $assetPath - $error',
            );
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
        );
      }
    } else {
      // Handle network/CDN profile pictures
      final isSvg = profileUrl.toLowerCase().endsWith('.svg');

      if (isSvg) {
        // Handle SVG profile pictures (from CDN) with error handling
        // Use errorBuilder to catch SVG parsing errors (async errors won't be caught by try-catch)
        profileWidget = SvgPicture.network(
          profileUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          // errorBuilder catches SVG parsing errors (like "unhandled element")
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
              '⚠️ [SOCIAL POST] Error loading SVG profile picture: $profileUrl - $error',
            );
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          semanticsLabel: 'Profile picture',
        );
      } else {
        // Handle regular image profile pictures
        profileWidget = CachedNetworkImage(
          imageUrl: profileUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          errorWidget: (context, url, error) {
            // Log error for debugging but don't block
            print(
              '⚠️ [SOCIAL POST] Error loading profile image: $url - $error',
            );
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          memCacheWidth: 80,
          memCacheHeight: 80,
          // Add timeout to prevent hanging
          httpHeaders: const {'Cache-Control': 'max-age=3600'},
        );
      }
    }

    if (widget.isSocialTab) {
      return ClipOval(child: profileWidget);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: profileWidget,
      );
    }
  }

  Widget _buildTagIcon(String iconPath) {
    // Tag icons are asset paths, use SafeSvgIcon for robust error handling
    if (iconPath.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use SafeSvgIcon which handles SVG parsing errors gracefully
    return SafeSvgIcon(
      assetPath: iconPath,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      fallback: const Icon(Icons.tag, size: 16, color: Colors.grey),
    );
  }

  Widget _buildImageCarousel(List<String> mediaUrls) {
    // If single image, no need for PageView
    if (mediaUrls.length == 1) {
      return RepaintBoundary(
        child: CachedNetworkImage(
          imageUrl: mediaUrls[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
          placeholder: (context, url) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          // Limit image resolution to prevent memory issues
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
          memCacheWidth: 800,
          memCacheHeight: 800,
        ),
      );
    }

    // Multiple images - use PageView
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController ?? PageController(),
            itemCount: mediaUrls.length,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
            },
            itemBuilder: (context, index) {
              return RepaintBoundary(
                key: ValueKey('image_$index'),
                child: CachedNetworkImage(
                  imageUrl: mediaUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  // Limit image resolution to prevent memory issues
                  maxWidthDiskCache: 800,
                  maxHeightDiskCache: 800,
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              mediaUrls.length,
              (index) => Container(
                key: ValueKey('dot_$index'),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildProfilePicture(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.post.timestamp,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Display tag icon if available (with safe async loading)
                  if (widget.post.tagIconUrl.isNotEmpty)
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: _buildTagIcon(widget.post.tagIconUrl),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz),
                ],
              ),
            ),

            // Post Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: LayoutBuilder(
                builder: (context, size) {
                  final textSpan = TextSpan(
                    text: widget.post.text,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  );
                  final textPainter = TextPainter(
                    text: textSpan,
                    maxLines: isTextExpanded ? null : 2,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: size.maxWidth);
                  final isOverflow = textPainter.didExceedMaxLines;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.text,
                        maxLines: isTextExpanded ? null : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOverflow)
                        GestureDetector(
                          onTap: () =>
                              setState(() => isTextExpanded = !isTextExpanded),
                          child: Text(
                            isTextExpanded ? "See less" : "See more",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Media
            if (widget.post.isVideo && _videoController != null)
              _videoController!.value.isInitialized
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.volume == 0) {
                            _videoController!.setVolume(1);
                          } else {
                            _videoController!.setVolume(0);
                          }
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    )
            else if (widget.post.mediaUrls != null &&
                widget.post.mediaUrls!.isNotEmpty)
              _buildImageCarousel(widget.post.mediaUrls!)
            else
              const SizedBox.shrink(),

            // Action Row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isLiking ? null : _handleLikeToggle,
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.favorite,
                            key: ValueKey(isLiked),
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text("${widget.post.likes}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentBottomSheet(
                          postId: widget.post.id,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment_outlined, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${widget.post.comments}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.share_outlined, color: Colors.grey),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${widget.post.views}"),
                    ],
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _isBookmarking ? null : _handleBookmarkToggle,
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border_outlined,
                            key: ValueKey(isBookmarked),
                            color: isBookmarked
                                ? Colors.grey[800]
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text("${widget.post.bookmarks}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
