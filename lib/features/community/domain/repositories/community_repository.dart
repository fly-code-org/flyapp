// domain/repositories/community_repository.dart
import '../entities/community.dart';
import '../entities/explore_search_result.dart';

abstract class CommunityRepository {
  Future<void> createCommunity({
    required String name,
    required String description,
    required String type,
    required String createdByType,
    required String logoPath,
    required int tagId,
  });
  Future<List<Community>> getCommunitiesByType(String type);
  /// Returns the current user's community for the given creator type (e.g. 'mhp'), or null.
  Future<Community?> getCommunity(String createdByType);
  /// Returns community by ID (for viewing any community).
  Future<Community?> getCommunityById(String communityId);
  /// Updates current user's community. createdByType e.g. 'mhp'. body: name, description, logo_path, tag_id, guidelines_*.
  Future<void> updateCommunity(String createdByType, Map<String, dynamic> body);
  /// Returns list of tags (map with tag_id, name, icon_path, type).
  Future<List<Map<String, dynamic>>> getTags();
  Future<void> followCommunity(String communityId);
  Future<void> unfollowCommunity(String communityId);
  Future<ExploreSearchResult> exploreSearch(String q);
}
