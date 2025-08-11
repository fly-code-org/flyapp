import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/start_quiz/widgets/card_options.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/features/start_quiz/widgets/number_picker.dart';
import 'package:fly/features/start_quiz/widgets/option_picker.dart';
import 'package:fly/features/start_quiz/widgets/vertical_progress_bar.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class UserQuestionFourthScreen extends StatefulWidget {
  const UserQuestionFourthScreen({super.key});

  @override
  State<UserQuestionFourthScreen> createState() => _UserQuestionFourthScreenState();
}

class _UserQuestionFourthScreenState extends State<UserQuestionFourthScreen> {
  double _dragPosition = 0.8;
  late final String role;

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
                          "What kind of support would you prefer when you're extremely upset",
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
                      GradientOptionSelector(
                        options: [
                          OptionItem(icon: Icons.favorite, label: "I REALLY NEED THIS!!"),
                          OptionItem(icon: Icons.favorite, label: "It matters a lot"),
                          OptionItem(icon: Icons.favorite, label: "It’s nice to have"),
                          OptionItem(icon: Icons.heart_broken, label: "I don’t need it"),
                        ],
                        onSelected: (index) {
                          print("Selected option: ${index + 1}");
                        },
                      ),
                      const SizedBox(height: 50),
                      GradientButton(
                        text: "Next >>>>",
                        onPressed: () {
                          Get.toNamed(AppRoutes.GetInterest);
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
