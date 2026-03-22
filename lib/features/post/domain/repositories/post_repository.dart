// domain/repositories/post_repository.dart
import '../entities/post.dart';
import '../entities/create_post_request.dart';

abstract class PostRepository {
  Future<void> createPost(CreatePostRequest request);
  // Backend gets authorId from JWT token, so no parameter needed
  Future<List<Post>> getPostsByAuthorId();
  Future<List<Post>> getPostsByCommunityId(String communityId);
  Future<List<Post>> getPostsByTagId(int tagId);
  Future<List<Post>> getPostsByIds(List<String> postIds);
  /// Feed: posts for home. typeFilter: "social" | "support" | null (all).
  Future<List<Post>> getFeed({int limit = 20, int offset = 0, String? typeFilter});
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> bookmarkPost(String postId);
  Future<void> unbookmarkPost(String postId);
  Future<void> sharePost(String postId);

  /// Cast a single vote on a poll option (backend enforces one vote per user per post).
  Future<void> votePoll(String postId, String optionId);
}



