// domain/usecases/unfollow_community.dart
import '../repositories/community_repository.dart';

class UnfollowCommunity {
  final CommunityRepository repository;

  UnfollowCommunity(this.repository);

  Future<void> call(String communityId) {
    return repository.unfollowCommunity(communityId);
  }
}

