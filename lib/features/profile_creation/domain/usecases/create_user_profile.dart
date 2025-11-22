// domain/usecases/create_user_profile.dart
import '../entities/user_profile_response.dart';
import '../repositories/user_profile_repository.dart';

class CreateUserProfile {
  final UserProfileRepository repository;

  CreateUserProfile(this.repository);

  Future<UserProfileResponse> call({
    required Map<String, dynamic> profileData,
  }) {
    return repository.createProfile(profileData: profileData);
  }
}

