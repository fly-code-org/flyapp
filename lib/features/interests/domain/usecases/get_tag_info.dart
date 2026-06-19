import '../repositories/interests_repository.dart';

class GetTagInfo {
  final InterestsRepository repository;

  GetTagInfo(this.repository);

  Future<Map<String, dynamic>> call(int tagId) {
    return repository.getTagInfo(tagId);
  }
}
