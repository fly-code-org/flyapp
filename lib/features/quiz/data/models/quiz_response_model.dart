import '../../../../core/error/exceptions.dart';
import '../../domain/entities/quiz_response.dart';
import 'question_model.dart';

class QuizResponseModel extends QuizResponse {
  QuizResponseModel({
    required super.message,
    required super.questions,
  });

  factory QuizResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['msg'] != null && json['msg'] is Map && json['msg']['error'] != null) {
      throw ServerException(
        json['msg']['error'].toString(),
        statusCode: 400,
      );
    }

    final message = json['msg']?.toString() ?? 'success';
    final List<dynamic>? questionsData = json['data'];

    if (questionsData == null) {
      throw ServerException(
        'Invalid response format: data is null',
        statusCode: 400,
      );
    }

    final questions = questionsData
        .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();

    return QuizResponseModel(
      message: message,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'data': questions.map((q) => (q as QuestionModel).toJson()).toList(),
    };
  }
}

