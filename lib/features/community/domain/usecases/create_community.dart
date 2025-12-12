// domain/usecases/create_community.dart
import '../repositories/community_repository.dart';

class CreateCommunity {
  final CommunityRepository repository;

  CreateCommunity(this.repository);

  Future<void> call({
    required String name,
    required String description,
    required String type,
    required String createdByType,
    required String logoPath,
    required int tagId,
  }) {
    return repository.createCommunity(
      name: name,
      description: description,
      type: type,
      createdByType: createdByType,
      logoPath: logoPath,
      tagId: tagId,
    );
  }
}

