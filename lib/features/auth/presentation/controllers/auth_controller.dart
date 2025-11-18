// presentation/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/user_verification_storage.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/usecases/google_login_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';

class AuthController extends GetxController {
  final SignupUser signupUser;
  final LoginUser loginUser;
  final GoogleLoginUser googleLoginUser;

  AuthController({
    required this.signupUser,
    required this.loginUser,
    required this.googleLoginUser,
  });

  var isLoading = false.obs;
  var token = ''.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;

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

      print('🎉 Google Signup completed successfully!');
      print('   ✅ Token stored securely');
      print('   ✅ API client configured');
      print('   📧 Email verified: ${response.isEmailVerified}');
      print('   📱 Phone verified: ${response.isPhoneVerified}');
      print('   ✅ Ready for navigation');
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
  }
}
