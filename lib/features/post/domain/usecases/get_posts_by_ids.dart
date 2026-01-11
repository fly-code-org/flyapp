// domain/usecases/get_posts_by_ids.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsByIds {
  final PostRepository repository;

  GetPostsByIds(this.repository);

  Future<List<Post>> call(List<String> postIds) async {
    return await repository.getPostsByIds(postIds);
  }
}

