import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class QuizIntroScreen extends StatefulWidget {
  const QuizIntroScreen({super.key});

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Track which button text to show
  bool _showSureLetsGo = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
    print("PhoneVerification role: $role");
  }

  void _handleButtonPressed() {
    if (_showSureLetsGo) {
      // Navigate with "Sure, let's go"
      Get.toNamed('/intro-quiz', arguments: {'text': "Sure, let's go"});
      setState(() {
        _showSureLetsGo = false; // Switch text on next render
      });
    } else {
      // Navigate with "Next >>>>"
      Get.toNamed('/intro-quiz', arguments: {'text': "Next >>>>"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
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
                    color: Colors.white.withValues(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      AnimatedOpacity(
                        opacity: _dragPosition > 0.1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Text(
                          "We’ve designed a few quick questions to better understand your journey.\n\n"
                          "Your insights will help us improve fly and create a more supportive space for everyone.",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            height: 50 / 40,
                            color: Color(0xFF8545E1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      GradientButton(
                        text: _showSureLetsGo ? "Sure, let's go!" : "Next >>>>",
                        onPressed: () {
                          if (_showSureLetsGo) {
                            if (role == 'mhp') {
                              Get.toNamed(AppRoutes.MHPQuestion1, arguments: {'role': role});
                            } else if (role == 'user') {
                              Get.toNamed(AppRoutes.UserQuestion1, arguments: {'role': role});
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (role == 'mhp') {
                              if (_showSureLetsGo) {
                                // Skip quiz: go straight to MHP profile creation
                                Get.toNamed(AppRoutes.createMhpProfile, arguments: {'role': role});
                              }
                            } else if (role == 'user') {
                              // For users, always go to Explore
                              Get.toNamed(AppRoutes.GetInterest);
                            }
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF8545E1), // purple
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
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
