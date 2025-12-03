import 'question.dart';

class QuizResponse {
  final String message;
  final List<Question> questions;

  QuizResponse({
    required this.message,
    required this.questions,
  });
}

