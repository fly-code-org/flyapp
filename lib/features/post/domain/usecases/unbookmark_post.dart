import '../../domain/repositories/post_repository.dart';

class UnbookmarkPost {
  final PostRepository repository;

  UnbookmarkPost(this.repository);

  Future<void> call(String postId) async {
    return await repository.unbookmarkPost(postId);
  }
}
