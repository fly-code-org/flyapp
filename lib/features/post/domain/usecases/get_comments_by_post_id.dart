// domain/usecases/get_comments_by_post_id.dart
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsByPostId {
  final CommentRepository repository;

  GetCommentsByPostId(this.repository);

  Future<List<Comment>> call(String postId) async {
    return await repository.getCommentsByPostId(postId);
  }
}
