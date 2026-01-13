// presentation/controllers/comment_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/create_comment_request.dart';
import '../../domain/usecases/get_comments_by_post_id.dart';
import '../../domain/usecases/get_replies_by_comment_id.dart';
import '../../domain/usecases/create_comment.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';

class CommentController extends GetxController {
  final GetCommentsByPostId getCommentsByPostId;
  final GetRepliesByCommentId getRepliesByCommentId;
  final CreateComment createComment;

  CommentController({
    GetCommentsByPostId? getCommentsByPostId,
    GetRepliesByCommentId? getRepliesByCommentId,
    CreateComment? createComment,
  }) : getCommentsByPostId = getCommentsByPostId ?? sl<GetCommentsByPostId>(),
       getRepliesByCommentId =
           getRepliesByCommentId ?? sl<GetRepliesByCommentId>(),
       createComment = createComment ?? sl<CreateComment>();

  // State
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var comments =
      <Comment>[].obs; // All comments (top-level + replies, flattened)
  var commentsByPostId =
      <String, List<Comment>>{}.obs; // Cache comments by post ID

  // Get comments by post ID (returns top-level comments only, replies are fetched separately)
  Future<void> fetchCommentsByPostId(
    String postId, {
    bool forceRefresh = false,
  }) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('💬 [COMMENT] Fetching comments for post ID: $postId');

      final fetchedComments = await getCommentsByPostId.call(postId);

      print(
        '📦 [COMMENT] Fetched ${fetchedComments.length} top-level comments',
      );

      // Store top-level comments
      commentsByPostId[postId] = fetchedComments;

      // Build flattened list with replies (fetch replies for each comment)
      final allComments = <Comment>[];
      for (var comment in fetchedComments) {
        allComments.add(comment);
        // Fetch replies for this comment
        if (comment.replyCount > 0) {
          try {
            final replies = await getRepliesByCommentId.call(comment.id);
            allComments.addAll(replies);
          } catch (e) {
            print(
              '⚠️ [COMMENT] Error fetching replies for comment ${comment.id}: $e',
            );
            // Continue even if replies fail
          }
        }
      }

      comments.value = allComments;
      print(
        '✅ [COMMENT] Total comments (including replies): ${allComments.length}',
      );
      isLoading.value = false;
    } on ServerException catch (e) {
      print('❌ [COMMENT] ServerException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } on NetworkException catch (e) {
      print('❌ [COMMENT] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e) {
      print('❌ [COMMENT] Unexpected error: $e');
      errorMessage.value = 'Failed to fetch comments: ${e.toString()}';
      isLoading.value = false;
    }
  }

  // Create a comment
  Future<bool> createCommentEntry({
    required String postId,
    String? parentCommentId,
    required String text,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('💬 [COMMENT] Creating comment...');
      print('   - Post ID: $postId');
      print('   - Parent Comment ID: ${parentCommentId ?? "null"}');
      print('   - Text: $text');

      final request = CreateCommentRequest(
        postId: postId,
        parentCommentId: parentCommentId,
        text: text.trim(),
      );

      await createComment.call(request);

      print('✅ [COMMENT] Comment created successfully');
      isLoading.value = false;

      // Refresh comments for this post
      await fetchCommentsByPostId(postId, forceRefresh: true);

      // Update streak (non-blocking, fire-and-forget)
      _updateStreakSilently();

      return true;
    } on ServerException catch (e) {
      print('❌ [COMMENT] ServerException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } on NetworkException catch (e) {
      print('❌ [COMMENT] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('❌ [COMMENT] Unexpected error: $e');
      errorMessage.value = 'Failed to create comment: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Get comments for a specific post (flattened with replies)
  List<Comment> getCommentsForPost(String postId) {
    return comments.where((c) => c.postId == postId).toList();
  }

  // Get top-level comments for a post
  List<Comment> getTopLevelCommentsForPost(String postId) {
    return comments
        .where((c) => c.postId == postId && c.parentCommentId == null)
        .toList();
  }

  // Get replies for a comment
  List<Comment> getRepliesForComment(String commentId) {
    return comments.where((c) => c.parentCommentId == commentId).toList();
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
        print(
          '⚠️ [COMMENT CONTROLLER] Streak update failed (non-blocking): $e',
        );
      });
    } catch (e) {
      // Silently fail if we can't get the controller
      print('⚠️ [COMMENT CONTROLLER] Could not update streak: $e');
    }
  }
}
