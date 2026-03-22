import '../repositories/mhp_profile_repository.dart';

class GetMhpProfileByUserId {
  final MhpProfileRepository repository;

  GetMhpProfileByUserId(this.repository);

  Future<Map<String, dynamic>> call(String userId) =>
      repository.getMhpProfileByUserId(userId);
}
