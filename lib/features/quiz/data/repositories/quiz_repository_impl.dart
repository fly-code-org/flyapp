import '../../domain/entities/quiz_response.dart';
import '../../domain/entities/answer_response.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl(this.remoteDataSource);

  @override
  Future<QuizResponse> getQuizQuestions({
    required String category,
    List<String>? tags,
  }) async {
    final response = await remoteDataSource.getQuizQuestions(
      category: category,
      tags: tags,
    );
    return response;
  }

  @override
  Future<AnswerResponse> submitAnswer({
    required String questionId,
    required String answer,
    String? optionId,
    List<String>? attachments,
  }) async {
    final response = await remoteDataSource.submitAnswer(
      questionId: questionId,
      answer: answer,
      optionId: optionId,
      attachments: attachments,
    );
    return response;
  }
}

