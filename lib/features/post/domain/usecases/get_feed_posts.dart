// domain/usecases/get_feed_posts.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetFeedPosts {
  final PostRepository repository;

  GetFeedPosts(this.repository);

  /// Returns feed posts. typeFilter: "social" | "support" | null (all). sortBy: "new" | "popular".
  Future<List<Post>> call({int limit = 20, int offset = 0, String? typeFilter, String sortBy = 'new'}) async {
    return await repository.getFeed(limit: limit, offset: offset, typeFilter: typeFilter, sortBy: sortBy);
  }
}
