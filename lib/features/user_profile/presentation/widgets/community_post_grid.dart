import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fly/features/post/presentation/controllers/post_controller.dart';
import 'package:fly/features/post/domain/entities/post.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityMediaSection extends StatefulWidget {
  final String type;
  final List<String>? postIds; // For Activities tab
  final List<Map<String, dynamic>>? bookmarkedPosts; // For Bookmarks tab

  const CommunityMediaSection({
    super.key,
    required this.type,
    this.postIds,
    this.bookmarkedPosts,
  });

  @override
  State<CommunityMediaSection> createState() => _CommunityMediaSectionState();
}

class _CommunityMediaSectionState extends State<CommunityMediaSection> {
  late PostController _postController;
  var isLoading = false.obs;
  var postsData = <Map<String, dynamic>>[].obs;
  List<String>? _lastFetchedIds; // Track last fetched IDs to avoid duplicate fetches

  @override
  void initState() {
    super.initState();
    // Get PostController
    if (Get.isRegistered<PostController>()) {
      _postController = Get.find<PostController>();
    } else {
      _postController = sl<PostController>();
      Get.put(_postController);
    }
    // Fetch posts when widget is created
    // Use addPostFrameCallback to ensure widget is fully built and data might be available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPostsIfNeeded();
    });
  }

  void _fetchPostsIfNeeded() {
    // Get current post IDs
    List<String> currentIds = [];
    if (widget.type == "Activities" && widget.postIds != null && widget.postIds!.isNotEmpty) {
      currentIds = widget.postIds!;
    } else if (widget.type == "Bookmarks" && widget.bookmarkedPosts != null && widget.bookmarkedPosts!.isNotEmpty) {
      currentIds = widget.bookmarkedPosts!
          .map((bookmark) => bookmark['post_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    }
    
    // Only fetch if we have IDs and they're different from last fetch
    if (currentIds.isNotEmpty) {
      final idsString = currentIds.join(',');
      final lastFetchedString = _lastFetchedIds?.join(',') ?? '';
      if (idsString != lastFetchedString) {
        _lastFetchedIds = List<String>.from(currentIds);
        _fetchPosts();
      }
    }
  }

  @override
  void didUpdateWidget(CommunityMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if post IDs or bookmarked posts changed
    if (_hasDataChanged(oldWidget)) {
      _fetchPostsIfNeeded();
    }
  }

  bool _hasDataChanged(CommunityMediaSection oldWidget) {
    if (widget.type != oldWidget.type) return true;
    
    if (widget.type == "Activities") {
      final oldIds = oldWidget.postIds ?? [];
      final newIds = widget.postIds ?? [];
      // Trigger fetch if data went from empty to non-empty
      if (oldIds.isEmpty && newIds.isNotEmpty) return true;
      // Trigger fetch if data went from non-empty to empty (reset)
      if (oldIds.isNotEmpty && newIds.isEmpty) return true;
      // Trigger fetch if lengths differ
      if (oldIds.length != newIds.length) return true;
      // Trigger fetch if any IDs differ
      for (var i = 0; i < oldIds.length; i++) {
        if (oldIds[i] != newIds[i]) return true;
      }
    } else if (widget.type == "Bookmarks") {
      final oldBookmarks = oldWidget.bookmarkedPosts ?? [];
      final newBookmarks = widget.bookmarkedPosts ?? [];
      // Trigger fetch if data went from empty to non-empty
      if (oldBookmarks.isEmpty && newBookmarks.isNotEmpty) return true;
      // Trigger fetch if data went from non-empty to empty (reset)
      if (oldBookmarks.isNotEmpty && newBookmarks.isEmpty) return true;
      // Trigger fetch if lengths differ
      if (oldBookmarks.length != newBookmarks.length) return true;
      // Trigger fetch if any bookmark IDs differ
      for (var i = 0; i < oldBookmarks.length; i++) {
        final oldId = oldBookmarks[i]['post_id'] as String? ?? '';
        final newId = newBookmarks[i]['post_id'] as String? ?? '';
        if (oldId != newId) return true;
      }
    }
    
    return false;
  }

  Future<void> _fetchPosts() async {
    try {
      isLoading.value = true;
      
      // Get post IDs based on type
      List<String> postIdsToFetch = [];
      
      if (widget.type == "Activities" && widget.postIds != null && widget.postIds!.isNotEmpty) {
        postIdsToFetch = widget.postIds!;
      } else if (widget.type == "Bookmarks" && 
                 widget.bookmarkedPosts != null && 
                 widget.bookmarkedPosts!.isNotEmpty) {
        // Extract post IDs from bookmarked_posts array in user_profile collection
        // Each bookmark is a Map with 'post_id' key
        postIdsToFetch = widget.bookmarkedPosts!
            .map((bookmark) => bookmark['post_id'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        
        print('📖 [COMMUNITY MEDIA] Bookmarked posts from user_profile: ${widget.bookmarkedPosts!.length}');
        print('   - Extracted post IDs: $postIdsToFetch');
      }
      
      if (postIdsToFetch.isEmpty) {
        postsData.value = [];
        isLoading.value = false;
        return;
      }
      
      print('🔍 [COMMUNITY MEDIA] Fetching posts for ${widget.type}...');
      print('   - Post IDs: $postIdsToFetch');
      
      // Store original posts list to restore after fetching
      final originalPosts = List<Post>.from(_postController.posts);
      
      try {
        // Fetch posts by IDs (this will update controller's posts temporarily)
        await _postController.fetchPostsByIds(postIdsToFetch);
        
        // Get fetched posts from controller
        final fetchedPosts = List<Post>.from(_postController.posts);
        
        // Convert posts to display format with image/video URLs
        final postsList = <Map<String, dynamic>>[];
        for (var post in fetchedPosts) {
          String? mediaUrl;
          String mediaType = 'text';
          
          // Get first image or video from attachments
          if (post.attachments.isNotEmpty) {
            final firstAttachment = post.attachments.first;
            mediaUrl = firstAttachment.url;
            mediaType = firstAttachment.type; // "image" or "video"
          } else if (post.content != null && post.content!.isNotEmpty) {
            // Text-only post
            mediaType = 'text';
          }
          
          postsList.add({
            "type": mediaType,
            "url": mediaUrl,
            "post_id": post.id,
            "content": post.content,
          });
        }
        
        postsData.value = postsList;
        print('✅ [COMMUNITY MEDIA] Fetched ${postsList.length} posts');
      } finally {
        // Restore original posts list in controller to avoid conflicts
        _postController.posts.value = originalPosts;
      }
    } catch (e) {
      print('❌ [COMMUNITY MEDIA] Error fetching posts: $e');
      postsData.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (postsData.isEmpty) {
        // No data - show empty state
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              widget.type == "Activities"
                  ? "No activities yet"
                  : "No bookmarks yet",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: postsData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          final post = postsData[index];
          final mediaType = post['type'] as String? ?? 'text';
          final mediaUrl = post['url'] as String?;
          final content = post['content'] as String?;

          Widget child;
          if (mediaType == "image" && mediaUrl != null && mediaUrl.isNotEmpty) {
            child = CachedNetworkImage(
              imageUrl: mediaUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          } else if (mediaType == "video" && mediaUrl != null && mediaUrl.isNotEmpty) {
            child = Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: mediaUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            );
          } else {
            // Text-only post or no media
            child = Container(
              color: Colors.grey[200],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    content ?? 'Text post',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  mediaType == "image"
                      ? Icons.photo
                      : mediaType == "video"
                      ? Icons.videocam
                      : Icons.text_snippet,
                  color: Colors.white,
                  size: 18,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
