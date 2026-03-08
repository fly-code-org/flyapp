// domain/usecases/get_mhp_profile.dart
import '../repositories/mhp_profile_repository.dart';

class GetMhpProfile {
  final MhpProfileRepository repository;

  GetMhpProfile(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getMhpProfile();
  }
}
