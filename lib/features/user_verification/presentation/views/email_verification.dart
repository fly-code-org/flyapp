import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/storage/onboarding_progress.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:fly/features/user_verification/presentation/controllers/verification_controller.dart';
import 'package:fly/features/user_verification/presentation/widgets/add_otp.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/user_verification/presentation/widgets/otp_verification_text.dart';
import 'package:get/get.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  double _dragPosition = 0.8;
  late final String role;
  late final String email;
  late final String phoneNumber;
  late final VerificationController _verificationController;
  String _otp = '';
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = args['role'] ?? 'user';
    email = args['email'] ?? '';
    phoneNumber = args['phone_number'] ?? '';
    print("Selected Role: $role");
    print("Email: $email");
    print("Phone: $phoneNumber");

    // Resume point if the app is killed on this step.
    OnboardingProgress.saveStep(
      step: AppRoutes.emailVerification,
      role: role,
      email: email,
      phoneNumber: phoneNumber,
    );

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

    _sendOtpOnInit();
  }

  Future<void> _sendOtpOnInit() async {
    if (email.isNotEmpty) {
      final success = await _verificationController.sendEmailOtp(
        email: email,
        purpose: 'signup',
      );
      if (success) {
        setState(() {
          _otpSent = true;
        });
        Get.snackbar(
          'OTP Sent',
          'Verification code sent to $email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _handleVerifyEmail() async {
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

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _verificationController.verifyEmailOtp(
      email: email,
      otp: _otp,
      purpose: 'signup',
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Email verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.toNamed('/phone-verification', arguments: {
        'role': role,
        'email': email,
        'phone_number': phoneNumber,
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (_verificationController.resendCooldown.value > 0) {
      return;
    }

    final success = await _verificationController.resendOtp(
      target: email,
      channel: 'email',
      purpose: 'signup',
    );

    if (success) {
      Get.snackbar(
        'OTP Resent',
        'New verification code sent to $email',
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
                      const EmailVerificationText(),
                      const SizedBox(height: 10),
                      Text(
                        email,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7A5AF8),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                      const SizedBox(height: 60),
                      if (_verificationController.errorMessage.value.isNotEmpty)
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
                            : _handleVerifyEmail,
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
