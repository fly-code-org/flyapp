import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/features/start_quiz/widgets/number_picker.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class UserQuestionThirdScreen extends StatefulWidget {
  const UserQuestionThirdScreen({super.key});

  @override
  State<UserQuestionThirdScreen> createState() =>
      _UserQuestionThirdScreenState();
}

class _UserQuestionThirdScreenState extends State<UserQuestionThirdScreen> {
  double _dragPosition = 0.8;
  late final String role;
  late final QuizController quizController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();

    // Get or create QuizController
    if (Get.isRegistered<QuizController>()) {
      quizController = Get.find<QuizController>();
    } else {
      quizController = sl<QuizController>();
      Get.put(quizController);
    }

    // Defer initialization to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuestion();
    });
  }

  Future<void> _initializeQuestion() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await quizController.fetchQuestions(category: role, tags: ['third']);

    if (quizController.errorMessage.value.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quizController.errorMessage.value)),
        );
      }
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
                      Obx(() {
                        final question = quizController.currentQuestion.value;
                        final isLoading = quizController.isLoading.value;

                        if (isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (question == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text('No question available'),
                            ),
                          );
                        }

                        final options = question.options;
                        final rightLabels = ["🤩", "😀", "😊", "😐", "😟"];
                        final adjustedRightLabels =
                            rightLabels.length >= options.length
                            ? rightLabels.sublist(0, options.length)
                            : [
                                ...rightLabels,
                                ...List.filled(
                                  options.length - rightLabels.length,
                                  "😐",
                                ),
                              ];
                        final optionTexts = options
                            .map((opt) => opt.optionText)
                            .toList();

                        return Column(
                          children: [
                            AnimatedOpacity(
                              opacity: _dragPosition > 0.1 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 27,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            PickerWithBall(
                              options: adjustedRightLabels,
                              labels: optionTexts,
                              displayFontSize: 60,
                              onChanged: (value, index) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (index >= 0 && index < options.length) {
                                    quizController.selectOption(
                                      options[index].id,
                                    );
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 50),
                            Obx(
                              () => GradientButton(
                                text: quizController.isSubmitting.value
                                    ? "Submitting..."
                                    : "Next >>>>",
                                onPressed:
                                    quizController
                                            .selectedOptionId
                                            .value
                                            .isEmpty ||
                                        quizController.isSubmitting.value
                                    ? () {
                                        if (quizController
                                            .selectedOptionId
                                            .value
                                            .isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select an option',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : () {
                                        quizController
                                            .submitCurrentAnswer()
                                            .then((success) {
                                              if (success) {
                                                Get.toNamed(
                                                  AppRoutes.UserQuestion4,
                                                );
                                              } else if (quizController
                                                  .submitError
                                                  .value
                                                  .isNotEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      quizController
                                                          .submitError
                                                          .value,
                                                    ),
                                                  ),
                                                );
                                              }
                                            });
                                      },
                              ),
                            ),
                          ],
                        );
                      }),
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
