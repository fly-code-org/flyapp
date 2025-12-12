// domain/usecases/get_communities_by_type.dart
import '../entities/community.dart';
import '../repositories/community_repository.dart';

class GetCommunitiesByType {
  final CommunityRepository repository;

  GetCommunitiesByType(this.repository);

  Future<List<Community>> call(String type) {
    return repository.getCommunitiesByType(type);
  }
}

