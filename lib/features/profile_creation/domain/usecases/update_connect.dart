import '../repositories/mhp_profile_repository.dart';

class UpdateConnect {
  final MhpProfileRepository repository;

  UpdateConnect(this.repository);

  Future<void> call(Map<String, dynamic> body) => repository.updateConnect(body);
}
