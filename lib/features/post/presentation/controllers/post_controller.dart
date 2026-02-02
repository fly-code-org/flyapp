// presentation/controllers/post_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/create_post_request.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/get_posts_by_author.dart';
import '../../domain/usecases/get_posts_by_community.dart';
import '../../domain/usecases/get_posts_by_tag.dart';
import '../../domain/usecases/get_posts_by_ids.dart';
import '../../domain/usecases/delete_post.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/unlike_post.dart';
import '../../domain/usecases/bookmark_post.dart';
import '../../domain/usecases/unbookmark_post.dart';
import '../../domain/usecases/share_post.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';

class PostController extends GetxController {
  final CreatePost createPost;
  final GetPostsByAuthor getPostsByAuthor;
  final GetPostsByCommunity getPostsByCommunity;
  final GetPostsByTag getPostsByTag;
  final GetPostsByIds getPostsByIds;
  final DeletePost deletePost;
  final LikePost likePost;
  final UnlikePost unlikePost;
  final BookmarkPost bookmarkPost;
  final UnbookmarkPost unbookmarkPost;
  final SharePost sharePost;

  PostController({
    CreatePost? createPost,
    GetPostsByAuthor? getPostsByAuthor,
    GetPostsByCommunity? getPostsByCommunity,
    GetPostsByTag? getPostsByTag,
    GetPostsByIds? getPostsByIds,
    DeletePost? deletePost,
    LikePost? likePost,
    UnlikePost? unlikePost,
    BookmarkPost? bookmarkPost,
    UnbookmarkPost? unbookmarkPost,
    SharePost? sharePost,
  })  : createPost = createPost ?? sl<CreatePost>(),
        getPostsByAuthor = getPostsByAuthor ?? sl<GetPostsByAuthor>(),
        getPostsByCommunity = getPostsByCommunity ?? sl<GetPostsByCommunity>(),
        getPostsByTag = getPostsByTag ?? sl<GetPostsByTag>(),
        getPostsByIds = getPostsByIds ?? sl<GetPostsByIds>(),
        deletePost = deletePost ?? sl<DeletePost>(),
        likePost = likePost ?? sl<LikePost>(),
        unlikePost = unlikePost ?? sl<UnlikePost>(),
        bookmarkPost = bookmarkPost ?? sl<BookmarkPost>(),
        unbookmarkPost = unbookmarkPost ?? sl<UnbookmarkPost>(),
        sharePost = sharePost ?? sl<SharePost>();

  // State
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var posts = <Post>[].obs;

  // Create post
  Future<bool> createPostEntry({
    required int tagId,
    String? content,
    List<Attachment> attachments = const [],
    Poll? poll,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('📝 [POST] Creating post...');
      print('   - Tag ID: $tagId');
      print('   - Content: ${content ?? "null"}');
      print('   - Attachments: ${attachments.length}');
      print('   - Has Poll: ${poll != null}');

      final request = CreatePostRequest(
        tagId: tagId,
        content: content?.trim().isEmpty == true ? null : content?.trim(),
        attachments: attachments,
        poll: poll,
      );

      await createPost.call(request);

      print('✅ [POST] Post created successfully');
      isLoading.value = false;
      
      // Update streak (non-blocking, fire-and-forget)
      _updateStreakSilently();
      
      return true;
    } on ServerException catch (e) {
      print('❌ [POST] ServerException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('❌ [POST] Unexpected error: $e');
      errorMessage.value = 'Failed to create post: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Get posts by author (current user)
  // Backend gets authorId from JWT token via x-fly-uuid header, so no parameter needed
  Future<void> fetchMyPosts({bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [POST] Fetching my posts...');
      print('   - Author ID will be extracted from JWT token by backend');
      
      final fetchedPosts = await getPostsByAuthor.call();
      
      posts.value = fetchedPosts;
      print('✅ [POST] Fetched ${fetchedPosts.length} posts');
      isLoading.value = false;
    } on ServerException catch (e) {
      print('❌ [POST] ServerException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } on NetworkException catch (e) {
      print('❌ [POST] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e) {
      print('❌ [POST] Unexpected error: $e');
      errorMessage.value = 'Failed to fetch posts: ${e.toString()}';
      isLoading.value = false;
    }
  }

  // Get posts by community
  Future<void> fetchPostsByCommunity(String communityId, {bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [POST] Fetching posts by community...');
      print('   - Community ID: $communityId');
      
      final fetchedPosts = await getPostsByCommunity.call(communityId);
      
      posts.value = fetchedPosts;
      print('✅ [POST] Fetched ${fetchedPosts.length} posts');
      isLoading.value = false;
    } on ServerException catch (e) {
      print('❌ [POST] ServerException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } on NetworkException catch (e) {
      print('❌ [POST] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e) {
      print('❌ [POST] Unexpected error: $e');
      errorMessage.value = 'Failed to fetch posts: ${e.toString()}';
      isLoading.value = false;
    }
  }

  // Get posts by tag ID
  Future<void> fetchPostsByTag(int tagId, {bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [POST CONTROLLER] Fetching posts by tag...');
      print('   - Tag ID: $tagId');
      
      final fetchedPosts = await getPostsByTag.call(tagId);
      
      print('📦 [POST CONTROLLER] Raw posts received: ${fetchedPosts.length}');
      if (fetchedPosts.isNotEmpty) {
        print('📝 [POST CONTROLLER] First post: id=${fetchedPosts.first.id}, tagId=${fetchedPosts.first.tagId}, content=${fetchedPosts.first.content}');
      }
      
      posts.value = fetchedPosts;
      print('✅ [POST CONTROLLER] Updated posts list with ${fetchedPosts.length} posts');
      isLoading.value = false;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to fetch posts: ${e.toString()}';
      isLoading.value = false;
    }
  }

  // Get posts by tag ID without updating controller state (for batch fetching)
  Future<List<Post>> fetchPostsByTagSilent(int tagId) async {
    try {
      print('🔍 [POST CONTROLLER] Fetching posts by tag (silent)...');
      print('   - Tag ID: $tagId');
      
      final fetchedPosts = await getPostsByTag.call(tagId);
      
      print('📦 [POST CONTROLLER] Raw posts received (silent): ${fetchedPosts.length}');
      return fetchedPosts;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Error fetching posts by tag (silent): $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      return []; // Return empty list on error to prevent breaking the batch fetch
    }
  }

  // Get posts by IDs
  Future<void> fetchPostsByIds(List<String> postIds, {bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;
    if (postIds.isEmpty) {
      posts.value = [];
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [POST CONTROLLER] Fetching posts by IDs...');
      print('   - Post IDs: ${postIds.length}');
      print('   - Post IDs list: $postIds');
      
      final fetchedPosts = await getPostsByIds.call(postIds);
      
      print('📦 [POST CONTROLLER] Raw posts received: ${fetchedPosts.length}');
      if (fetchedPosts.isNotEmpty) {
        print('📝 [POST CONTROLLER] First post: id=${fetchedPosts.first.id}');
      }
      
      posts.value = fetchedPosts;
      print('✅ [POST CONTROLLER] Updated posts list with ${fetchedPosts.length} posts');
      isLoading.value = false;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to fetch posts: ${e.toString()}';
      isLoading.value = false;
    }
  }

  // Delete post
  Future<bool> deletePostEntry(String postId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🗑️ [POST CONTROLLER] Deleting post...');
      print('   - Post ID: $postId');
      
      await deletePost.call(postId);
      
      // Remove from local list
      posts.removeWhere((post) => post.id == postId);
      
      print('✅ [POST CONTROLLER] Post deleted successfully');
      isLoading.value = false;
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to delete post: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Like post
  Future<bool> likePostEntry(String postId) async {
    try {
      print('❤️ [POST CONTROLLER] Liking post...');
      print('   - Post ID: $postId');
      
      await likePost.call(postId);
      
      print('✅ [POST CONTROLLER] Post liked successfully');
      
      // Update streak (non-blocking, fire-and-forget)
      _updateStreakSilently();
      
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to like post: ${e.toString()}';
      return false;
    }
  }

  // Unlike post
  Future<bool> unlikePostEntry(String postId) async {
    try {
      print('💔 [POST CONTROLLER] Unliking post...');
      print('   - Post ID: $postId');
      
      await unlikePost.call(postId);
      
      print('✅ [POST CONTROLLER] Post unliked successfully');
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to unlike post: ${e.toString()}';
      return false;
    }
  }

  // Bookmark post
  Future<bool> bookmarkPostEntry(String postId) async {
    try {
      print('🔖 [POST CONTROLLER] Bookmarking post...');
      print('   - Post ID: $postId');

      await bookmarkPost.call(postId);

      print('✅ [POST CONTROLLER] Post bookmarked successfully');
      
      // Update streak (non-blocking, fire-and-forget)
      _updateStreakSilently();
      
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to bookmark post: ${e.toString()}';
      return false;
    }
  }

  // Unbookmark post
  Future<bool> unbookmarkPostEntry(String postId) async {
    try {
      print('🔓 [POST CONTROLLER] Unbookmarking post...');
      print('   - Post ID: $postId');

      await unbookmarkPost.call(postId);

      print('✅ [POST CONTROLLER] Post unbookmarked successfully');
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to unbookmark post: ${e.toString()}';
      return false;
    }
  }

  // Share post
  Future<bool> sharePostEntry(String postId) async {
    try {
      print('📤 [POST CONTROLLER] Sharing post...');
      print('   - Post ID: $postId');

      await sharePost.call(postId);

      print('✅ [POST CONTROLLER] Post shared successfully');
      return true;
    } on ServerException catch (e) {
      print('❌ [POST CONTROLLER] ServerException: ${e.message}');
      print('❌ [POST CONTROLLER] Status code: ${e.statusCode}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [POST CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e, stackTrace) {
      print('❌ [POST CONTROLLER] Unexpected error: $e');
      print('❌ [POST CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Failed to share post: ${e.toString()}';
      return false;
    }
  }

  // Clear error
  void clearError() {
    errorMessage.value = '';
  }

  // Helper method to update streak silently (non-blocking)
  void _updateStreakSilently() {
    try {
      // Get UserProfileController from service locator or GetX
      UserProfileController? profileController;
      if (Get.isRegistered<UserProfileController>()) {
        profileController = Get.find<UserProfileController>();
      } else {
        profileController = sl<UserProfileController>();
        Get.put(profileController, permanent: true);
      }
      
      // Call updateStreak in a fire-and-forget manner
      profileController.updateStreak().catchError((e) {
        // Silently fail - don't block user activities if streak update fails
        print('⚠️ [POST CONTROLLER] Streak update failed (non-blocking): $e');
      });
    } catch (e) {
      // Silently fail if we can't get the controller
      print('⚠️ [POST CONTROLLER] Could not update streak: $e');
    }
  }
}



