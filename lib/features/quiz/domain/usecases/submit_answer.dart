import '../entities/answer_response.dart';
import '../repositories/quiz_repository.dart';

class SubmitAnswer {
  final QuizRepository repository;

  SubmitAnswer(this.repository);

  Future<AnswerResponse> call({
    required String questionId,
    required String answer,
    String? optionId,
    List<String>? attachments,
  }) {
    return repository.submitAnswer(
      questionId: questionId,
      answer: answer,
      optionId: optionId,
      attachments: attachments,
    );
  }
}

