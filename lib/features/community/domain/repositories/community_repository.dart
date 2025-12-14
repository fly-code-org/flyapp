// domain/repositories/community_repository.dart
import '../entities/community.dart';

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
  Future<void> followCommunity(String communityId);
  Future<void> unfollowCommunity(String communityId);
}
