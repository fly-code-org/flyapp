import '../repositories/community_repository.dart';

class UpdateCommunity {
  final CommunityRepository repository;

  UpdateCommunity(this.repository);

  Future<void> call(String createdByType, Map<String, dynamic> body) =>
      repository.updateCommunity(createdByType, body);
}
