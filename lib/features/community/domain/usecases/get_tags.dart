import '../repositories/community_repository.dart';

class GetTags {
  final CommunityRepository repository;

  GetTags(this.repository);

  Future<List<Map<String, dynamic>>> call() => repository.getTags();
}
