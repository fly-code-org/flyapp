import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/user_verification/presentation/controllers/verification_controller.dart';
import 'package:fly/features/user_verification/presentation/widgets/add_otp.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_text.dart';
import 'package:fly/features/user_verification/presentation/widgets/not_recieved_otp.dart';
import 'package:fly/features/user_verification/presentation/widgets/phone_number_input_field.dart';
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
  late final VerificationController _verificationController;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase(); // normalize to lowercase
    print("PhoneVerification role: $role");

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
        // Navigate based on role only on success
        if (role == 'user') {
          Get.toNamed('/create-user-profile', arguments: {
            'role': role,
            'phone': phoneController.text.trim(),
          });
        } else {
          Get.toNamed('/create-mhp-profile', arguments: {
            'role': role,
            'phone': phoneController.text.trim(),
          });
        }
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose(); // clean up
    super.dispose();
  }

  Future<void> _handleVerifyPhone() async {
    // Validate phone number
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

    // Call verification API
    await _verificationController.verifyPhoneOtp(
      phoneNumber: phone,
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
                        "Feel free to share your number",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PhoneNumberInputField(controller: phoneController),
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
                      const SizedBox(height: 60),
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
                            : _handleVerifyPhone,
                      ),
                      const SizedBox(height: 20),
                      GradientTextButton(
                        text: "<Skip for now>",
                        onTap: () {
                          if (role == 'user') {
                            Get.toNamed('/create-user-profile', arguments: {'role': role});
                          } else {
                            Get.toNamed('/create-mhp-profile', arguments: {'role': role});
                          }
                        },
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
