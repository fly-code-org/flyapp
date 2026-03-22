import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/user_profile/presentation/widgets/profile_card.dart';
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
import 'package:fly/core/services/share_service.dart';

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
  bool _isSharing = false;
  late PostController _postController;
  UserProfileController? _userProfileController;
  late int _commentCount; // Local comment count for optimistic updates

  /// Local poll state after voting (optimistic) until feed refresh.
  UiPoll? _pollLocal;
  bool _voteSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize local comment count from widget.post.comments
    _commentCount = widget.post.comments;
    _pollLocal = widget.post.poll;
    
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
  void didUpdateWidget(SocialPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local comment count with widget.post.comments when post is updated from server
    if (oldWidget.post.comments != widget.post.comments) {
      _commentCount = widget.post.comments;
    }
    if (oldWidget.post.id == widget.post.id &&
        oldWidget.post.poll != widget.post.poll) {
      _pollLocal = widget.post.poll;
    }
  }

  UiPoll? get _effectivePoll => _pollLocal ?? widget.post.poll;

  bool _pollExpired(UiPoll p) =>
      DateTime.now().toUtc().isAfter(p.expiresAt.toUtc());

  bool _userHasVotedOnPoll(UiPoll p, String? userId) {
    if (userId == null || userId.isEmpty) return false;
    for (final o in p.options) {
      if (o.votes.contains(userId)) return true;
    }
    return false;
  }

  UiPoll _applyVote(UiPoll p, String userId, String optionId) {
    return UiPoll(
      question: p.question,
      expiresAt: p.expiresAt,
      options: p.options
          .map(
            (o) => o.optionId == optionId
                ? o.copyWith(votes: [...o.votes, userId])
                : o,
          )
          .toList(),
    );
  }

  Future<void> _onPollOptionTap(String optionId) async {
    if (_voteSubmitting) return;
    final poll = _effectivePoll;
    if (poll == null) return;

    final token = ApiClient.getAuthToken();
    final userId =
        token != null && token.isNotEmpty ? JwtDecoder.getUserId(token) : null;
    if (userId == null || userId.isEmpty) return;
    if (_pollExpired(poll) || _userHasVotedOnPoll(poll, userId)) return;

    setState(() => _voteSubmitting = true);
    final ok = await _postController.votePollEntry(widget.post.id, optionId);
    if (!mounted) return;
    setState(() => _voteSubmitting = false);

    if (ok) {
      setState(() {
        _pollLocal = _applyVote(poll, userId, optionId);
      });
      widget.onRefreshNeeded?.call();
    } else {
      final msg = _postController.errorMessage.value;
      if (msg.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  Widget _buildPollSection(UiPoll poll) {
    final token = ApiClient.getAuthToken();
    final userId =
        token != null && token.isNotEmpty ? JwtDecoder.getUserId(token) : null;
    final expired = _pollExpired(poll);
    final voted = _userHasVotedOnPoll(poll, userId);
    final canVote =
        !expired && !voted && userId != null && userId.isNotEmpty;

    var totalVotes = 0;
    for (final o in poll.options) {
      totalVotes += o.votes.length;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.poll, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    poll.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (expired)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Poll ended',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            if (!expired && voted)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'You voted',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            const SizedBox(height: 10),
            ...poll.options.map((o) {
              final n = o.votes.length;
              final pct =
                  totalVotes == 0 ? 0.0 : (100.0 * n / totalVotes);
              final isMine =
                  userId != null && o.votes.contains(userId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: canVote && !_voteSubmitting
                        ? () => _onPollOptionTap(o.optionId)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isMine
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalVotes == 0 ? 0 : n / totalVotes,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isMine
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (totalVotes > 0)
              Text(
                '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  /// Handles optimistic comment count update when a comment is added
  void _handleCommentAdded() {
    if (mounted) {
      setState(() {
        _commentCount++; // Increment count optimistically
      });
      // Trigger refresh to sync with server (similar to like/bookmark)
      if (widget.onRefreshNeeded != null) {
        widget.onRefreshNeeded!();
      }
    }
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

    // Optimistic UI update - update bookmark state (icon only, count will update from server)
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

  Future<void> _handleShareWithContext(BuildContext shareIconContext) async {
    // Prevent multiple simultaneous share operations
    if (_isSharing) {
      print('⚠️ [SOCIAL POST] Share operation already in progress, ignoring click');
      return;
    }

    // Set flag immediately to prevent multiple clicks
    _isSharing = true;

    try {
      print('📤 [SOCIAL POST] Attempting to share post: ${widget.post.id}');
      
      // Call share service to open native share dialog
      // Pass context for iPad share position (use shareIconContext for accurate positioning)
      final shareSuccess = await ShareService.sharePost(
        postId: widget.post.id,
        postText: widget.post.text,
        username: widget.post.username,
        context: shareIconContext,
      );

      if (shareSuccess) {
        print('✅ [SOCIAL POST] Share dialog opened successfully');
        
        // Track share count on backend (fire and forget - don't block UI)
        // Note: We don't wait for this to complete, as the user has already shared
        _postController.sharePostEntry(widget.post.id).catchError((e) {
          print('⚠️ [SOCIAL POST] Failed to track share count: $e');
          // Don't show error to user - share was successful, just tracking failed
          return false;
        });
        
        // Refresh posts to get updated share count (non-blocking)
        if (widget.onRefreshNeeded != null) {
          // Delay refresh slightly to allow backend to update
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onRefreshNeeded!();
          });
        }
      } else {
        print('❌ [SOCIAL POST] Share dialog failed to open');
        // Optionally show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open share dialog'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [SOCIAL POST] Error sharing post: $e');
      print('📚 [SOCIAL POST] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share post'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isSharing = false;
    }
  }

  Widget _buildProfilePicture() {
    final avatar = ProfileAvatar(
      imagePath: widget.post.profileUrl,
      userId: widget.post.authorId.isNotEmpty ? widget.post.authorId : null,
      size: 40,
      dense: true,
    );
    if (widget.isSocialTab) {
      return avatar;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: avatar,
    );
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
          if (widget.post.text.trim().isNotEmpty)
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

          if (_effectivePoll != null) _buildPollSection(_effectivePoll!),

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
                          onCommentAdded: _handleCommentAdded,
                        ),
                      );
                    },
                    child: Row(
                  children: [
                    const Icon(Icons.comment_outlined, color: Colors.grey),
                    const SizedBox(width: 4),
                        Text("$_commentCount"),
                  ],
                    ),
                ),
                const SizedBox(width: 16),
                Builder(
                  builder: (shareIconContext) => GestureDetector(
                    onTap: _isSharing ? null : () => _handleShareWithContext(shareIconContext),
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: _isSharing ? Colors.grey[400] : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text("${widget.post.shares}"),
                      ],
                    ),
                  ),
                ),
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
