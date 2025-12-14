// domain/usecases/follow_community.dart
import '../repositories/community_repository.dart';

class FollowCommunity {
  final CommunityRepository repository;

  FollowCommunity(this.repository);

  Future<void> call(String communityId) {
    return repository.followCommunity(communityId);
  }
}

