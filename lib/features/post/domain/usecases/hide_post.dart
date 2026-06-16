import '../repositories/post_repository.dart';

class HidePost {
  final PostRepository repository;
  HidePost(this.repository);

  Future<void> call(String postId) async {
    return await repository.hidePost(postId);
  }
}
