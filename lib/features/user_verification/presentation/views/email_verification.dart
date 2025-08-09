import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = args['role'] ?? 'user'; // Default to 'user' if null
    print("Selected Role: $role"); // For debugging
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
                    EnterOtpWidget(),
                    const SizedBox(height: 30),
                    NotRecievedOTP(),
                    const SizedBox(height: 100),
                    GradientButton(
                      text: "Verify and Continue",
                      onPressed: () {
                        Get.toNamed('/phone-verification', arguments: {
                          'role': role,
                        });
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
