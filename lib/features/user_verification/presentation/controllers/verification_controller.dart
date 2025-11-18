// presentation/controllers/verification_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/verify_email.dart';
import '../../domain/usecases/verify_phone.dart';

class VerificationController extends GetxController {
  final VerifyEmail verifyEmail;
  final VerifyPhone verifyPhone;

  VerificationController({
    required this.verifyEmail,
    required this.verifyPhone,
  });

  var isLoading = false.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🔐 Starting email verification...');
    print('📧 Email: $email');
    print('🔢 OTP: $otp');

    try {
      final response = await verifyEmail(
        email: email,
        otp: otp,
      );

      print('✅ Email verification successful');
      print('📨 Response message: ${response.message}');

      message.value = response.message;
      return true; // Success
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false; // Failure
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false; // Failure
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false; // Failure
    } finally {
      isLoading.value = false;
      print('🏁 Email verification process completed');
    }
  }

  Future<bool> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🔐 Starting phone verification...');
    print('📱 Phone: $phoneNumber');
    print('🔢 OTP: $otp');

    try {
      final response = await verifyPhone(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      print('✅ Phone verification successful');
      print('📨 Response message: ${response.message}');

      message.value = response.message;
      return true; // Success
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false; // Failure
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false; // Failure
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false; // Failure
    } finally {
      isLoading.value = false;
      print('🏁 Phone verification process completed');
    }
  }
}

