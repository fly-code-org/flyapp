import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/features/start_quiz/widgets/vertical_progress_bar.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MhpQuestionOneScreen extends StatefulWidget {
  const MhpQuestionOneScreen({super.key});

  @override
  State<MhpQuestionOneScreen> createState() => _MhpQuestionOneScreenState();
}

class _MhpQuestionOneScreenState extends State<MhpQuestionOneScreen> {
  double _dragPosition = 0.8;
  late final String role;
  late final QuizController quizController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'mhp').toLowerCase();

    // Get or create QuizController
    if (Get.isRegistered<QuizController>()) {
      quizController = Get.find<QuizController>();
      print("✅ [MHP FIRST QUESTION] Found existing QuizController");
    } else {
      quizController = sl<QuizController>();
      Get.put(quizController);
      print("✅ [MHP FIRST QUESTION] Created and registered new QuizController");
    }

    // Defer initialization to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeQuestion();
    });
  }

  Future<void> _initializeQuestion() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await quizController.fetchQuestions(category: role, tags: ['first']);

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
                        final leftLabels = options
                            .map((opt) => opt.optionText)
                            .toList();
                        final rightLabels = ["🤩", "😀", "😊", "😐", "😟"];

                        // Adjust right labels to match left labels count
                        final adjustedRightLabels =
                            rightLabels.length >= leftLabels.length
                            ? rightLabels.sublist(0, leftLabels.length)
                            : [
                                ...rightLabels,
                                ...List.filled(
                                  leftLabels.length - rightLabels.length,
                                  "😐",
                                ),
                              ];

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
                            VerticalOptionsSelector(
                              leftLabels: leftLabels,
                              rightLabels: adjustedRightLabels,
                              onOptionSelected: (index, _) {
                                // Defer state update to avoid calling setState during build
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                // VerticalOptionsSelector uses reversed index: 0 = bottom, length-1 = top
                                // But our options array is in normal order: 0 = first option
                                // So we need to reverse the index to match
                                final reversedIndex =
                                    (options.length - 1) - index;
                                print(
                                  '📌 [MHP FIRST QUESTION] Option selected - visual index: $index, reversed index: $reversedIndex, total options: ${options.length}',
                                );
                                if (reversedIndex >= 0 &&
                                    reversedIndex < options.length) {
                                    final selectedOption =
                                        options[reversedIndex];
                                    print(
                                      '✅ [MHP FIRST QUESTION] Selecting option: ${selectedOption.optionText} (id: "${selectedOption.id}")',
                                    );
                                    if (selectedOption.id.isEmpty) {
                                  print(
                                        '❌ [MHP FIRST QUESTION] Option ID is empty!',
                                  );
                                      return;
                                    }
                                  quizController.selectOption(
                                    selectedOption.id,
                                  );
                                  print(
                                      '✅ [MHP FIRST QUESTION] Selected option ID set to: "${quizController.selectedOptionId.value}"',
                                  );
                                } else {
                                  print(
                                    '❌ [MHP FIRST QUESTION] Invalid reversed index: $reversedIndex (options length: ${options.length})',
                                  );
                                }
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              final selectedOptionId =
                                  quizController.selectedOptionId.value;
                              final isSubmitting =
                                  quizController.isSubmitting.value;
                              final canSubmit =
                                  selectedOptionId.isNotEmpty && !isSubmitting;

                              print(
                                '🔄 [MHP FIRST QUESTION] Button rebuild - selectedOptionId: "$selectedOptionId", canSubmit: $canSubmit',
                              );

                              return GradientButton(
                                text: isSubmitting
                                    ? "Submitting..."
                                    : "Next >>>>",
                                onPressed: canSubmit
                                    ? () {
                                        print(
                                          '🚀 [MHP FIRST QUESTION] Submitting answer with optionId: "$selectedOptionId"',
                                        );
                                        quizController
                                            .submitCurrentAnswer()
                                            .then((success) {
                                              if (success) {
                                                Get.toNamed(
                                                  AppRoutes.MHPQuestion2,
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
                                      }
                                    : () {
                                        print(
                                          '⚠️ [MHP FIRST QUESTION] Button clicked but cannot submit - selectedOptionId: "$selectedOptionId", isSubmitting: $isSubmitting',
                                        );
                                        if (selectedOptionId.isEmpty) {
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
                                      },
                              );
                            }),
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
