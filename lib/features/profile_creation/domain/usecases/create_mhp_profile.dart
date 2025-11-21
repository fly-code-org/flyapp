// domain/usecases/create_mhp_profile.dart
import '../entities/mhp_profile_response.dart';
import '../repositories/mhp_profile_repository.dart';

class CreateMhpProfile {
  final MhpProfileRepository repository;

  CreateMhpProfile(this.repository);

  Future<MhpProfileResponse> call({
    required Map<String, dynamic> profileData,
  }) {
    return repository.createProfile(profileData: profileData);
  }
}

