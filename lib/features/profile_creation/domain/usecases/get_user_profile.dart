// domain/usecases/get_user_profile.dart
import '../repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getUserProfile();
  }
}

