// domain/repositories/comment_repository.dart
import '../entities/comment.dart';
import '../entities/create_comment_request.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentsByPostId(String postId);
  Future<List<Comment>> getRepliesByCommentId(String commentId);
  Future<void> createComment(CreateCommentRequest request);
}
