import '../entities/quiz_response.dart';
import '../entities/answer_response.dart';

abstract class QuizRepository {
  Future<QuizResponse> getQuizQuestions({
    required String category,
    List<String>? tags,
  });

  Future<AnswerResponse> submitAnswer({
    required String questionId,
    required String answer,
    String? optionId,
    List<String>? attachments,
  });
}

