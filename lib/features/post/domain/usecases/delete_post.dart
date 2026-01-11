// domain/usecases/delete_post.dart
import '../repositories/post_repository.dart';

class DeletePost {
  final PostRepository repository;

  DeletePost(this.repository);

  Future<void> call(String postId) async {
    return await repository.deletePost(postId);
  }
}

