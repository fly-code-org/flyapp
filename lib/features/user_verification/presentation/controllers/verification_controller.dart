import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/repositories/verification_repository.dart';

class VerificationController extends GetxController {
  final VerificationRepository repository;

  VerificationController({required this.repository});

  var isLoading = false.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;
  var resendCooldown = 0.obs;

  Future<bool> sendEmailOtp({
    required String email,
    String purpose = 'signup',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('📧 Sending OTP to email: $email');

    try {
      final response = await repository.sendEmailOtp(
        email: email,
        purpose: purpose,
      );

      print('✅ OTP sent successfully');
      message.value = response.message;
      resendCooldown.value = 30;
      _startResendCooldown();
      AnalyticsService.otpRequested(channel: 'email');
      return true;
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
    String purpose = 'signup',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🔐 Verifying email OTP: $email');

    try {
      final response = await repository.verifyEmailOtp(
        email: email,
        otp: otp,
        purpose: purpose,
      );

      print('✅ Email verification successful');
      message.value = response.message;
      AnalyticsService.otpVerified(channel: 'email');
      return true;
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      AnalyticsService.otpFailed(channel: 'email', attemptNumber: 1);
      return false;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPhoneOtp({
    required String phoneNumber,
    String purpose = 'signup',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('📱 Sending OTP to phone: $phoneNumber');

    try {
      final response = await repository.sendPhoneOtp(
        phoneNumber: phoneNumber,
        purpose: purpose,
      );

      print('✅ OTP sent successfully');
      message.value = response.message;
      resendCooldown.value = 30;
      _startResendCooldown();
      AnalyticsService.otpRequested(channel: 'sms');
      return true;
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    String purpose = 'signup',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    message.value = '';

    print('🔐 Verifying phone OTP: $phoneNumber');

    try {
      final response = await repository.verifyPhoneOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        purpose: purpose,
      );

      print('✅ Phone verification successful');
      message.value = response.message;
      AnalyticsService.otpVerified(channel: 'sms');
      return true;
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      AnalyticsService.otpFailed(channel: 'sms', attemptNumber: 1);
      return false;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resendOtp({
    required String target,
    required String channel,
    String purpose = 'signup',
  }) async {
    if (resendCooldown.value > 0) {
      errorMessage.value = 'Please wait ${resendCooldown.value} seconds';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    print('🔄 Resending OTP to $target via $channel');

    try {
      final response = await repository.resendOtp(
        target: target,
        channel: channel,
        purpose: purpose,
      );

      print('✅ OTP resent successfully');
      message.value = response.message;
      resendCooldown.value = 30;
      _startResendCooldown();
      AnalyticsService.otpResent(channel: channel);
      return true;
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendCooldown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
        return true;
      }
      return false;
    });
  }
}
