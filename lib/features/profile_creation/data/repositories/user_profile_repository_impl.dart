// data/repositories/user_profile_repository_impl.dart
import '../../domain/entities/user_profile_response.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  UserProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserProfileResponse> createProfile({
    required Map<String, dynamic> profileData,
  }) async {
    final response = await remoteDataSource.createProfile(
      profileData: profileData,
    );
    return response;
  }
}

