import '../repositories/mhp_profile_repository.dart';

class GetAboutMe {
  final MhpProfileRepository repository;

  GetAboutMe(this.repository);

  Future<Map<String, dynamic>> call() => repository.getAboutMe();
}
