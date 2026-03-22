/// Poll data for home feed cards (mirrors API `poll` object).
class UiPollOption {
  final String optionId;
  final String text;
  final List<String> votes;

  const UiPollOption({
    required this.optionId,
    required this.text,
    this.votes = const [],
  });

  UiPollOption copyWith({
    String? optionId,
    String? text,
    List<String>? votes,
  }) {
    return UiPollOption(
      optionId: optionId ?? this.optionId,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}

class UiPoll {
  final String question;
  final DateTime expiresAt;
  final List<UiPollOption> options;

  const UiPoll({
    required this.question,
    required this.expiresAt,
    required this.options,
  });

  UiPoll copyWith({
    String? question,
    DateTime? expiresAt,
    List<UiPollOption>? options,
  }) {
    return UiPoll(
      question: question ?? this.question,
      expiresAt: expiresAt ?? this.expiresAt,
      options: options ?? this.options,
    );
  }
}
