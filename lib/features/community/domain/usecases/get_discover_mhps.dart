import '../entities/explore_search_result.dart';
import '../repositories/community_repository.dart';

/// Paginated "Discover Mental Health Professionals" list (Explore "See All").
class GetDiscoverMhps {
  final CommunityRepository repository;

  GetDiscoverMhps(this.repository);

  Future<DiscoverMhpsResult> call({int skip = 0, int limit = 20}) =>
      repository.getDiscoverMhps(skip: skip, limit: limit);
}
