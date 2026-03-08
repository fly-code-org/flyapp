import '../entities/community.dart';
import '../repositories/community_repository.dart';

class GetCommunityById {
  final CommunityRepository repository;

  GetCommunityById(this.repository);

  Future<Community?> call(String communityId) => repository.getCommunityById(communityId);
}
