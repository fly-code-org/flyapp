import '../entities/explore_search_result.dart';
import '../repositories/community_repository.dart';

class SearchExplore {
  final CommunityRepository repository;

  SearchExplore(this.repository);

  Future<ExploreSearchResult> call(String q) => repository.exploreSearch(q);
}
