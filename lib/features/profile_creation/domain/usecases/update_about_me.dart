import '../repositories/mhp_profile_repository.dart';

class UpdateAboutMe {
  final MhpProfileRepository repository;

  UpdateAboutMe(this.repository);

  Future<void> call(Map<String, dynamic> body) => repository.updateAboutMe(body);
}
