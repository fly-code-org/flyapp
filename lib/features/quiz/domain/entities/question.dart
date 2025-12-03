import 'question_option.dart';

class Question {
  final String id;
  final String question;
  final List<String> tags;
  final String category;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.question,
    required this.tags,
    required this.category,
    required this.options,
  });
}

