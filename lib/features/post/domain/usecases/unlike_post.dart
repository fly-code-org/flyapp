// domain/usecases/unlike_post.dart
import '../../domain/repositories/post_repository.dart';

class UnlikePost {
  final PostRepository repository;

  UnlikePost(this.repository);

  Future<void> call(String postId) async {
    return await repository.unlikePost(postId);
  }
}
