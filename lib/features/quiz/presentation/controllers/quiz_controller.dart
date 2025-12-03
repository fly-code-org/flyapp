import 'package:get/get.dart';
import '../../domain/entities/question.dart';
import '../../domain/usecases/get_quiz_questions.dart';
import '../../domain/usecases/submit_answer.dart';
import '../../../../core/error/exceptions.dart';

class QuizController extends GetxController {
  final GetQuizQuestions getQuizQuestions;
  final SubmitAnswer submitAnswer;

  QuizController({
    required this.getQuizQuestions,
    required this.submitAnswer,
  });

  // Observable state
  final RxList<Question> questions = <Question>[].obs;
  final Rx<Question?> currentQuestion = Rx<Question?>(null);
  final RxString selectedOptionId = ''.obs;
  final RxString answerText = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;

  // Track current question index
  final RxInt currentQuestionIndex = 0.obs;

  /// Fetch questions based on category and tags
  Future<void> fetchQuestions({
    required String category,
    List<String>? tags,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🔍 [QUIZ CONTROLLER] Fetching questions...');
      print('   - Category: $category');
      print('   - Tags: $tags');

      final response = await getQuizQuestions(
        category: category,
        tags: tags,
      );

      questions.value = response.questions;
      print('✅ [QUIZ CONTROLLER] Fetched ${questions.length} questions');

      // Clear previous selections when fetching new questions
      selectedOptionId.value = '';
      answerText.value = '';

      if (questions.isNotEmpty) {
        currentQuestion.value = questions[0];
        currentQuestionIndex.value = 0;
      } else {
        errorMessage.value = 'No questions found';
      }
    } on ServerException catch (e) {
      print('❌ [QUIZ CONTROLLER] ServerException: ${e.message}');
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      print('❌ [QUIZ CONTROLLER] NetworkException: ${e.message}');
      errorMessage.value = 'Network error: ${e.message}';
    } catch (e) {
      print('❌ [QUIZ CONTROLLER] Unexpected error: $e');
      errorMessage.value = 'An unexpected error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Select an option for the current question
  void selectOption(String optionId) {
    if (optionId.isEmpty) {
      print('⚠️ [QUIZ CONTROLLER] Attempted to select empty option ID');
      return;
    }
    selectedOptionId.value = optionId;
    print('📌 [QUIZ CONTROLLER] Selected option: $optionId');
    print('📌 [QUIZ CONTROLLER] selectedOptionId.value is now: "${selectedOptionId.value}"');
  }

  /// Set answer text for the current question
  void setAnswerText(String text) {
    answerText.value = text;
  }

  /// Submit answer for the current question
  Future<bool> submitCurrentAnswer({List<String>? attachments}) async {
    if (currentQuestion.value == null) {
      submitError.value = 'No question selected';
      return false;
    }

    if (answerText.value.isEmpty && selectedOptionId.value.isEmpty) {
      submitError.value = 'Please select an option or provide an answer';
      return false;
    }

    try {
      isSubmitting.value = true;
      submitError.value = '';
      print('📤 [QUIZ CONTROLLER] Submitting answer...');
      print('   - Question ID: ${currentQuestion.value!.id}');
      print('   - Answer: ${answerText.value}');
      print('   - Option ID: ${selectedOptionId.value}');

      final response = await submitAnswer(
        questionId: currentQuestion.value!.id,
        answer: answerText.value.isNotEmpty
            ? answerText.value
            : 'Selected option',
        optionId: selectedOptionId.value.isNotEmpty
            ? selectedOptionId.value
            : null,
        attachments: attachments,
      );

      print('✅ [QUIZ CONTROLLER] Answer submitted successfully');
      print('   - Response: ${response.message}');

      // Clear current answer
      selectedOptionId.value = '';
      answerText.value = '';

      return true;
    } on AuthException catch (e) {
      print('❌ [QUIZ CONTROLLER] AuthException: ${e.message}');
      submitError.value = e.message;
      // Could trigger logout here
      return false;
    } on ServerException catch (e) {
      print('❌ [QUIZ CONTROLLER] ServerException: ${e.message}');
      submitError.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [QUIZ CONTROLLER] NetworkException: ${e.message}');
      submitError.value = 'Network error: ${e.message}';
      return false;
    } catch (e) {
      print('❌ [QUIZ CONTROLLER] Unexpected error: $e');
      submitError.value = 'An unexpected error occurred: $e';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      currentQuestion.value = questions[currentQuestionIndex.value];
      selectedOptionId.value = '';
      answerText.value = '';
      submitError.value = '';
    }
  }

  /// Move to previous question
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      currentQuestion.value = questions[currentQuestionIndex.value];
      selectedOptionId.value = '';
      answerText.value = '';
      submitError.value = '';
    }
  }

  /// Get question by tag (first, second, third, fourth)
  Question? getQuestionByTag(String tag) {
    try {
      return questions.firstWhere(
        (q) => q.tags.contains(tag.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  /// Reset controller state
  void reset() {
    questions.clear();
    currentQuestion.value = null;
    selectedOptionId.value = '';
    answerText.value = '';
    currentQuestionIndex.value = 0;
    errorMessage.value = '';
    submitError.value = '';
  }
}

