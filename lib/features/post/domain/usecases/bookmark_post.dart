import '../../domain/repositories/post_repository.dart';

class BookmarkPost {
  final PostRepository repository;

  BookmarkPost(this.repository);

  Future<void> call(String postId) async {
    return await repository.bookmarkPost(postId);
  }
}
