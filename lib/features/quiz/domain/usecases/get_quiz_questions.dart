import '../entities/quiz_response.dart';
import '../repositories/quiz_repository.dart';

class GetQuizQuestions {
  final QuizRepository repository;

  GetQuizQuestions(this.repository);

  Future<QuizResponse> call({
    required String category,
    List<String>? tags,
  }) {
    return repository.getQuizQuestions(
      category: category,
      tags: tags,
    );
  }
}

