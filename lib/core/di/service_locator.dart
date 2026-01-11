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
import '../../features/profile_creation/domain/usecases/get_user_profile.dart';
import '../../features/user_profile/presentation/controllers/user_profile_controller.dart';
import '../../features/journal/presentation/controllers/journal_controller.dart';
import '../../features/file_upload/data/datasources/upload_remote_data_source.dart';
import '../../features/file_upload/data/repositories/upload_repository_impl.dart';
import '../../features/file_upload/domain/repositories/upload_repository.dart';
import '../../features/file_upload/domain/usecases/get_presigned_url.dart';
import '../../features/quiz/data/datasources/quiz_remote_data_source.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/get_quiz_questions.dart';
import '../../features/quiz/domain/usecases/submit_answer.dart';
import '../../features/quiz/presentation/controllers/quiz_controller.dart';
import '../../features/interests/data/datasources/interests_remote_data_source.dart';
import '../../features/interests/data/repositories/interests_repository_impl.dart';
import '../../features/interests/domain/repositories/interests_repository.dart';
import '../../features/interests/domain/usecases/follow_tag.dart';
import '../../features/interests/domain/usecases/save_interests.dart';
import '../../features/interests/domain/usecases/unfollow_tag.dart';
import '../../features/community/data/datasources/community_remote_data_source.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/create_community.dart';
import '../../features/community/domain/usecases/follow_community.dart';
import '../../features/community/domain/usecases/get_communities_by_type.dart';
import '../../features/community/domain/usecases/unfollow_community.dart';
import '../../features/journal/data/datasources/journal_remote_data_source.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/domain/usecases/get_journals.dart';
import '../../features/journal/domain/usecases/create_journal.dart';
import '../../features/journal/domain/usecases/update_journal.dart';
import '../../features/journal/domain/usecases/get_color_templates.dart';
import '../../features/journal/domain/usecases/create_color_template.dart';
import '../../features/post/data/datasources/post_remote_data_source.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';
import '../../features/post/domain/usecases/create_post.dart';
import '../../features/post/domain/usecases/get_posts_by_author.dart';
import '../../features/post/domain/usecases/get_posts_by_community.dart';
import '../../features/post/domain/usecases/get_posts_by_tag.dart';
import '../../features/post/domain/usecases/get_posts_by_ids.dart';
import '../../features/post/domain/usecases/delete_post.dart';
import '../../features/post/domain/usecases/like_post.dart';
import '../../features/post/domain/usecases/unlike_post.dart';
import '../../features/post/presentation/controllers/post_controller.dart';
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
      createUserProfile: sl(), // Optional: for auto-saving profile on Google signup
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
  sl.registerLazySingleton(() => GetUserProfile(sl()));

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

  //! Features - Quiz
  // Controllers
  sl.registerFactory(
    () => QuizController(
      getQuizQuestions: sl(),
      submitAnswer: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetQuizQuestions(sl()));
  sl.registerLazySingleton(() => SubmitAnswer(sl()));

  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - Interests
  // Use cases
  sl.registerLazySingleton(() => SaveInterests(sl()));
  sl.registerLazySingleton(() => FollowTag(sl()));
  sl.registerLazySingleton(() => UnfollowTag(sl()));

  // Repository
  sl.registerLazySingleton<InterestsRepository>(
    () => InterestsRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<InterestsRemoteDataSource>(
    () => InterestsRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - Community
  // Use cases
  sl.registerLazySingleton(() => CreateCommunity(sl()));
  sl.registerLazySingleton(() => GetCommunitiesByType(sl()));
  sl.registerLazySingleton(() => FollowCommunity(sl()));
  sl.registerLazySingleton(() => UnfollowCommunity(sl()));

  // Repository
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - User Profile
  // Controllers
  sl.registerLazySingleton(() => UserProfileController());

  //! Features - Journal
  // Controllers
  sl.registerLazySingleton(() => JournalController());

  //! Features - Journal
  // Use cases
  sl.registerLazySingleton(() => GetJournals(sl()));
  sl.registerLazySingleton(() => CreateJournal(sl()));
  sl.registerLazySingleton(() => UpdateJournal(sl()));
  sl.registerLazySingleton(() => GetColorTemplates(sl()));
  sl.registerLazySingleton(() => CreateColorTemplate(sl()));

  // Repository
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<JournalRemoteDataSource>(
    () => JournalRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Features - Post
  // Controllers
  sl.registerFactory(
    () => PostController(
      createPost: sl(),
      getPostsByAuthor: sl(),
      getPostsByCommunity: sl(),
      getPostsByTag: sl(),
      getPostsByIds: sl(),
      deletePost: sl(),
      likePost: sl(),
      unlikePost: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreatePost(sl()));
  sl.registerLazySingleton(() => GetPostsByAuthor(sl()));
  sl.registerLazySingleton(() => GetPostsByCommunity(sl()));
  sl.registerLazySingleton(() => GetPostsByTag(sl()));
  sl.registerLazySingleton(() => GetPostsByIds(sl()));
  sl.registerLazySingleton(() => DeletePost(sl()));
  sl.registerLazySingleton(() => LikePost(sl()));
  sl.registerLazySingleton(() => UnlikePost(sl()));

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dio: ApiClient.dio),
  );

  //! Core
  // Note: ApiClient.dio is already a singleton, so we don't need to register it
}
