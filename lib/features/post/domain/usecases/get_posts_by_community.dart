// domain/usecases/get_posts_by_community.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsByCommunity {
  final PostRepository repository;

  GetPostsByCommunity(this.repository);

  Future<List<Post>> call(String communityId) async {
    return await repository.getPostsByCommunityId(communityId);
  }
}



