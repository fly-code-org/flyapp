// domain/usecases/share_post.dart
import '../../domain/repositories/post_repository.dart';

class SharePost {
  final PostRepository repository;

  SharePost(this.repository);

  Future<void> call(String postId) async {
    return await repository.sharePost(postId);
  }
}
