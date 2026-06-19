// domain/usecases/get_posts_by_tag.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsByTag {
  final PostRepository repository;

  GetPostsByTag(this.repository);

  Future<List<Post>> call(int tagId, {String postType = 'all'}) async {
    return await repository.getPostsByTagId(tagId, postType: postType);
  }
}

