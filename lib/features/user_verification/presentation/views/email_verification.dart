import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/user_verification/presentation/controllers/verification_controller.dart';
import 'package:fly/features/user_verification/presentation/widgets/add_otp.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/user_verification/presentation/widgets/not_recieved_otp.dart';
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
  late final VerificationController _verificationController;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = args['role'] ?? 'user'; // Default to 'user' if null
    email = args['email'] ?? ''; // Get email from arguments
    print("Selected Role: $role"); // For debugging
    print("Email: $email"); // For debugging
    
    // Get VerificationController from dependency injection
    _verificationController = sl<VerificationController>();
    
    // Listen to controller changes
    ever(_verificationController.isLoading, (isLoading) {
      if (mounted) setState(() {});
    });
    ever(_verificationController.errorMessage, (error) {
      if (mounted && error.isNotEmpty) {
        // Show error message
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
    ever(_verificationController.message, (message) {
      if (mounted && message.isNotEmpty) {
        // Success - navigate to next screen
        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to phone verification only on success
        Get.toNamed('/phone-verification', arguments: {
          'role': role,
          'email': email,
        });
      }
    });
  }
  
  Future<void> _handleVerifyEmail() async {
    // Validate OTP
    if (_otp.isEmpty || _otp.length != 4) {
      Get.snackbar(
        'Error',
        'Please enter a valid 4-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Validate email
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
    
    // Call verification API
    await _verificationController.verifyEmailOtp(
      email: email,
      otp: _otp,
    );
    
    // Navigation is handled in the ever() listener above
    // Only navigates if success is true (message is set)
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
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ), // Placeholder for test content
                    const SizedBox(height: 20),
                    const EmailVerificationText(),
                    const SizedBox(height: 40),
                    EnterOtpWidget(
                      onOtpChanged: (otp) {
                        setState(() {
                          _otp = otp;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    NotRecievedOTP(),
                    const SizedBox(height: 100),
                    // Show error message if any
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
}
