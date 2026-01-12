// domain/usecases/create_comment.dart
import '../entities/create_comment_request.dart';
import '../repositories/comment_repository.dart';

class CreateComment {
  final CommentRepository repository;

  CreateComment(this.repository);

  Future<void> call(CreateCommentRequest request) async {
    return await repository.createComment(request);
  }
}
