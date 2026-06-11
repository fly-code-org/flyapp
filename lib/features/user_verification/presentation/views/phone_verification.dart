import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/user_verification/presentation/controllers/verification_controller.dart';
import 'package:fly/features/user_verification/presentation/widgets/add_otp.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_text.dart';
import 'package:fly/features/user_verification/presentation/widgets/phone_number_input_field.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  double _dragPosition = 0.8;
  final phoneController = TextEditingController();
  late final String role;
  late final String email;
  late final VerificationController _verificationController;
  String _otp = '';
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    email = args['email'] ?? '';
    final passedPhone = args['phone_number'] ?? '';
    if (passedPhone.isNotEmpty) {
      phoneController.text = passedPhone;
    }
    print("PhoneVerification role: $role");
    print("PhoneVerification email: $email");

    _verificationController = sl<VerificationController>();

    ever(_verificationController.isLoading, (isLoading) {
      if (mounted) setState(() {});
    });
    ever(_verificationController.errorMessage, (error) {
      if (mounted && error.isNotEmpty) {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
    ever(_verificationController.resendCooldown, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    phone = phone.trim();
    if (!phone.startsWith('+')) {
      if (phone.startsWith('91') && phone.length == 12) {
        return '+$phone';
      }
      return '+91$phone';
    }
    return phone;
  }

  Future<void> _handleSendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final formattedPhone = _formatPhoneNumber(phone);
    final success = await _verificationController.sendPhoneOtp(
      phoneNumber: formattedPhone,
      purpose: 'signup',
    );

    if (success) {
      setState(() {
        _otpSent = true;
      });
      Get.snackbar(
        'OTP Sent',
        'Verification code sent to $formattedPhone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleVerifyPhone() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_otp.isEmpty || _otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final formattedPhone = _formatPhoneNumber(phone);
    final success = await _verificationController.verifyPhoneOtp(
      phoneNumber: formattedPhone,
      otp: _otp,
      purpose: 'signup',
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Phone verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (role == 'user') {
      Get.toNamed('/create-user-profile', arguments: {
        'role': role,
        'phone': phoneController.text.trim(),
      });
    } else {
      Get.toNamed(AppRoutes.IntroScreen, arguments: {
        'role': role,
        'phone': phoneController.text.trim(),
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (_verificationController.resendCooldown.value > 0) {
      return;
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final formattedPhone = _formatPhoneNumber(phone);
    final success = await _verificationController.resendOtp(
      target: formattedPhone,
      channel: 'sms',
      purpose: 'signup',
    );

    if (success) {
      Get.snackbar(
        'OTP Resent',
        'New verification code sent to $formattedPhone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fly.png',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _dragPosition > 0.3
                ? 50
                : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: 100,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _dragPosition = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Center(
                        child: Text(
                          "Create your account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 27,
                            fontWeight: FontWeight.w400,
                            height: 33.75 / 27,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Verify your phone number",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "This step is optional but recommended for account recovery",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PhoneNumberInputField(controller: phoneController),
                      const SizedBox(height: 16),
                      if (!_otpSent)
                        GradientButton(
                          text: _verificationController.isLoading.value
                              ? "Sending..."
                              : "Send OTP",
                          onPressed: _verificationController.isLoading.value
                              ? () {}
                              : _handleSendOtp,
                        ),
                      if (_otpSent) ...[
                        const SizedBox(height: 20),
                        EnterOtpWidget(
                          length: 6,
                          onOtpChanged: (otp) {
                            setState(() {
                              _otp = otp;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildResendOtpButton(),
                        const SizedBox(height: 40),
                        if (_verificationController
                            .errorMessage.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _verificationController.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        GradientButton(
                          text: _verificationController.isLoading.value
                              ? "Verifying..."
                              : "Verify and Continue",
                          onPressed: _verificationController.isLoading.value
                              ? () {}
                              : _handleVerifyPhone,
                        ),
                      ],
                      const SizedBox(height: 20),
                      GradientTextButton(
                        text: "<Skip for now>",
                        onTap: _navigateToNextScreen,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResendOtpButton() {
    final cooldown = _verificationController.resendCooldown.value;
    final canResend = cooldown == 0;

    return GestureDetector(
      onTap: canResend ? _handleResendOtp : null,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 14,
            color: Colors.black,
          ),
          children: [
            const TextSpan(text: "Didn't receive the code? "),
            TextSpan(
              text: canResend ? "Resend OTP" : "Resend in ${cooldown}s",
              style: TextStyle(
                color: canResend ? const Color(0xFF7A5AF8) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
