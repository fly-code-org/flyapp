// presentation/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/user_verification_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../features/user_profile/data/utils/default_profile_picture.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/usecases/google_login_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../../profile_creation/domain/usecases/create_user_profile.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../../../core/di/service_locator.dart' as sl;

class AuthController extends GetxController {
  final SignupUser signupUser;
  final LoginUser loginUser;
  final GoogleLoginUser googleLoginUser;
  final CreateUserProfile? createUserProfile;

  AuthController({
    required this.signupUser,
    required this.loginUser,
    required this.googleLoginUser,
    this.createUserProfile,
  });

  var isLoading = false.obs;
  var token = ''.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;
  var isNewUser = false.obs; // Indicates if a new user was created (for Google login)

  Future<void> signup({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    try {
      final AuthResponse response = await signupUser(
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        password: password,
        phoneNumber: phoneNumber,
        email: email,
        role: role,
      );

      // Store token securely
      await TokenStorage.saveToken(response.token);

      // Update API client with token for future requests
      ApiClient.updateAuthToken(response.token);

      token.value = response.token;
      message.value = response.message;
    } on ServerException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }

  // Method to get stored token
  Future<String?> getStoredToken() async {
    return await TokenStorage.getToken();
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🚀 AuthController: Starting login API call');
    print('📧 Email: $email');

    try {
      final AuthResponse response = await loginUser(
        email: email,
        password: password,
      );

      print('✅ Login API call successful');
      print('📨 Response message: ${response.message}');
      print('🎫 Token received: ${response.token.isNotEmpty}');

      // Store token securely
      await TokenStorage.saveToken(response.token);
      print('💾 Token saved to secure storage');

      // Update API client with token for future requests
      ApiClient.updateAuthToken(response.token);
      print('🔧 API client updated with auth token');

      token.value = response.token;
      message.value = response.message;

      // Prefetch user profile after successful login
      _prefetchUserProfile();
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print('🏁 Login process completed');
    }
  }

  // Auto-save username and picture_path for new Google users
  Future<void> _autoSaveProfileForNewGoogleUser(String token) async {
    try {
      print('🎲 [AUTH] Auto-saving profile for new Google user...');
      
      // Get user ID from JWT token
      final userId = JwtDecoder.getUserId(token);
      if (userId == null || userId.isEmpty) {
        print('⚠️ [AUTH] Could not get user ID from token');
        return;
      }
      
      // Generate random username
      String username;
      try {
        final jwtUsername = JwtDecoder.getUserName(token);
        if (jwtUsername != null && jwtUsername.isNotEmpty) {
          username = jwtUsername;
        } else {
          // Generate fallback username from user ID
          username = 'user_${userId.substring(0, 8)}';
        }
      } catch (e) {
        // Generate fallback username from user ID
        username = 'user_${userId.substring(0, 8)}';
      }
      
      // Get random profile picture path (relative path for backend)
      final picturePath = DefaultProfilePicture.getRandomProfilePicturePath(userId);
      
      print('🎲 [AUTH] Generated username: "$username"');
      print('🎲 [AUTH] Generated picture_path: "$picturePath"');
      
      // Create profile data
      final profileData = <String, dynamic>{
        'username': username,
        'picture_path': picturePath,
      };
      
      // Call create profile API if available
      if (createUserProfile != null) {
        print('🚀 [AUTH] Calling create profile API...');
        try {
          final response = await createUserProfile!.call(profileData: profileData);
          print('✅ [AUTH] Profile auto-saved successfully: ${response.message}');
        } catch (e) {
          print('⚠️ [AUTH] Error auto-saving profile (non-fatal): $e');
          // Don't fail login if profile save fails - it's optional
        }
      } else {
        print('⚠️ [AUTH] CreateUserProfile use case not available');
        // Try to get it from service locator
        try {
          final createUserProfileFromSl = sl.sl<CreateUserProfile>();
          print('🚀 [AUTH] Calling create profile API (from service locator)...');
          final response = await createUserProfileFromSl.call(profileData: profileData);
          print('✅ [AUTH] Profile auto-saved successfully: ${response.message}');
        } catch (e) {
          print('⚠️ [AUTH] Error getting CreateUserProfile from service locator: $e');
        }
      }
    } catch (e, stackTrace) {
      print('⚠️ [AUTH] Error auto-saving profile for new Google user: $e');
      print('📚 [AUTH] Stack trace: $stackTrace');
      // Don't fail login if profile save fails - it's optional
    }
  }

  // Prefetch user profile after login
  void _prefetchUserProfile() {
    try {
      // Use service locator to get controller
      final profileController = sl.sl<UserProfileController>();
      // Register it with GetX if not already registered
      if (!Get.isRegistered<UserProfileController>()) {
        Get.put(profileController, permanent: true);
      }
      profileController.fetchUserProfile(forceRefresh: true);
      print('✅ [AUTH] Prefetching user profile...');
    } catch (e) {
      print('⚠️ [AUTH] Error prefetching profile: $e');
      // Don't fail login if profile prefetch fails
    }
  }

  Future<void> googleLogin({
    required String accessToken,
    required String role,
    String? currentPlatform,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🚀 AuthController: Starting Google login API call');
    print('👤 Role: $role');

    try {
      final AuthResponse response = await googleLoginUser(
        accessToken: accessToken,
        role: role,
        currentPlatform: currentPlatform,
      );

      print('✅ Google login API call successful');
      print('📨 Response message: ${response.message}');
      print('🎫 Token received: ${response.token.isNotEmpty}');
      if (response.token.isNotEmpty) {
        print(
          '   Token preview: ${response.token.substring(0, response.token.length > 30 ? 30 : response.token.length)}...',
        );
      }

      await TokenStorage.saveToken(response.token);
      print('💾 Token saved to secure storage');

      ApiClient.updateAuthToken(response.token);
      print('🔧 API client updated with auth token');

      // Store email verification status for Google auth
      if (response.isEmailVerified) {
        await UserVerificationStorage.setEmailVerified(true);
        print('✅ Email verification status stored: true (Google auth)');
      }

      // Store phone verification status if available
      if (response.isPhoneVerified) {
        await UserVerificationStorage.setPhoneVerified(true);
        print('✅ Phone verification status stored: true');
      }

      token.value = response.token;
      message.value = response.message;
      isNewUser.value = response.isNewUser;

      print('🎉 Google login completed successfully!');
      print('   ✅ Token stored securely');
      print('   ✅ API client configured');
      print('   📧 Email verified: ${response.isEmailVerified}');
      print('   📱 Phone verified: ${response.isPhoneVerified}');
      print('   🆕 Is new user: ${response.isNewUser}');
      print('   ✅ Ready for navigation');

      // If new user, auto-save username and picture_path immediately
      if (response.isNewUser) {
        await _autoSaveProfileForNewGoogleUser(response.token);
      } else {
        // Prefetch user profile after successful login (only if not a new user)
        _prefetchUserProfile();
      }
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print('🏁 Google login process completed');
    }
  }

  // Method to logout
  Future<void> logout() async {
    await TokenStorage.deleteToken();
    await UserVerificationStorage.clearVerificationStatus();
    ApiClient.clearAuthToken();
    token.value = '';
    message.value = '';
    errorMessage.value = '';
    isNewUser.value = false;
  }
}
