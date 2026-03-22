// data/models/nira_message_model.dart
// API response model for NIRA message (snake_case from backend View).

class NiraMessageModel {
  final String id;
  final String userId;
  final String sessionId;
  final int messageIndex;
  final String userMessage;
  final String? niraResponse;
  final DateTime timeStamp;
  final List<String> emotion;
  final String? intent;

  const NiraMessageModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.messageIndex,
    required this.userMessage,
    this.niraResponse,
    required this.timeStamp,
    this.emotion = const [],
    this.intent,
  });

  factory NiraMessageModel.fromJson(Map<String, dynamic> json) {
    return NiraMessageModel(
      id: _parseId(json['_id']),
      userId: _parseId(json['user_id']),
      sessionId: _parseId(json['session_id']),
      messageIndex: (json['message_index'] as num?)?.toInt() ?? 0,
      userMessage: (json['user_message'] as String?) ?? '',
      niraResponse: json['nira_response'] as String?,
      timeStamp: _parseDateTime(json['time_stamp']),
      emotion: (json['emotion'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      intent: json['intent'] as String?,
    );
  }

  static String _parseId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey(r'$oid')) return value[r'$oid'] as String;
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
