import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/start_quiz/widgets/card_options.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/features/start_quiz/widgets/vertical_progress_bar.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MhpQuestionThirdScreen extends StatefulWidget {
  const MhpQuestionThirdScreen({super.key});

  @override
  State<MhpQuestionThirdScreen> createState() => _MhpQuestionThirdScreenState();
}

class _MhpQuestionThirdScreenState extends State<MhpQuestionThirdScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Track which button text to show
  bool _showSureLetsGo = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
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
                          "How important is a safe, anonymous space for mental wellness?",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 27,
                            fontWeight: FontWeight.normal,
                            // color: Color(0xFF8545E1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      OptionsGrid(
                        emojis: [
                          '🧘‍♂️',
                          '🌧️',
                          '💔',
                          '🚫',
                          '🌱',
                          '👨‍👩‍👧‍👦',
                        ],
                        labels: [
                          'Anxiety & Stress Management',
                          'Depression & Mood Disorders',
                          'Trauma & Grief counseling',
                          'Addiction & Substance Abuse',
                          'Self-Esteem & Personal Growth',
                          'Family & Relationship Counseling',
                        ],
                        onOptionSelected: (index) {
                          print("Selected option: $index");
                        },
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: "Next >>>>",
                        onPressed: () {
                          Get.toNamed(AppRoutes.MHPQuestion4);
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
