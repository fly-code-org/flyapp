// core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_sources.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/google_login_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/signup_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/user_verification/data/datasources/verification_remote_data_source.dart';
import '../../features/user_verification/data/repositories/verification_repository_impl.dart';
import '../../features/user_verification/domain/repositories/verification_repository.dart';
import '../../features/user_verification/domain/usecases/verify_email.dart';
import '../../features/user_verification/domain/usecases/verify_phone.dart';
import '../../features/user_verification/presentation/controllers/verification_controller.dart';
import '../../features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';
import '../../features/profile_creation/data/datasources/user_profile_remote_data_source.dart';
import '../../features/profile_creation/data/repositories/mhp_profile_repository_impl.dart';
import '../../features/profile_creation/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile_creation/domain/repositories/mhp_profile_repository.dart';
import '../../features/profile_creation/domain/repositories/user_profile_repository.dart';
import '../../features/profile_creation/domain/usecases/create_mhp_profile.dart';
import '../../features/profile_creation/domain/usecases/create_user_profile.dart';
import '../../features/file_upload/data/datasources/upload_remote_data_source.dart';
import '../../features/file_upload/data/repositories/upload_repository_impl.dart';
import '../../features/file_upload/domain/repositories/upload_repository.dart';
import '../../features/file_upload/domain/usecases/get_presigned_url.dart';
import '../services/s3_upload_service.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  //! Features - Auth
  // Controllers
  sl.registerFactory(
    () => AuthController(
      signupUser: sl(),
      loginUser: sl(),
      googleLoginUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignupUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GoogleLoginUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - User Verification
  // Controllers
  sl.registerFactory(
    () => VerificationController(verifyEmail: sl(), verifyPhone: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => VerifyPhone(sl()));

  // Repository
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - Profile Creation (MHP)
  // Use cases
  sl.registerLazySingleton(() => CreateMhpProfile(sl()));

  // Repository
  sl.registerLazySingleton<MhpProfileRepository>(
    () => MhpProfileRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<MhpProfileRemoteDataSource>(
    () => MhpProfileRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - Profile Creation (User)
  // Use cases
  sl.registerLazySingleton(() => CreateUserProfile(sl()));

  // Repository
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - File Upload
  // Services
  sl.registerLazySingleton(() => S3UploadService(getPresignedUrl: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetPresignedUrl(sl()));

  // Repository
  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => UploadRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Core
  // Note: ApiClient.dio is already a singleton, so we don't need to register it
}
