// domain/usecases/get_replies_by_comment_id.dart
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetRepliesByCommentId {
  final CommentRepository repository;

  GetRepliesByCommentId(this.repository);

  Future<List<Comment>> call(String commentId) async {
    return await repository.getRepliesByCommentId(commentId);
  }
}
