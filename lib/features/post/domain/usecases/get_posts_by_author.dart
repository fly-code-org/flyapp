// domain/usecases/get_posts_by_author.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsByAuthor {
  final PostRepository repository;

  GetPostsByAuthor(this.repository);

  // Backend gets authorId from JWT token, so no parameter needed
  Future<List<Post>> call() async {
    return await repository.getPostsByAuthorId();
  }
}



