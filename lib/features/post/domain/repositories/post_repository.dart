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
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
}



