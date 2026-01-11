// domain/usecases/like_post.dart
import '../../domain/repositories/post_repository.dart';

class LikePost {
  final PostRepository repository;

  LikePost(this.repository);

  Future<void> call(String postId) async {
    return await repository.likePost(postId);
  }
}
