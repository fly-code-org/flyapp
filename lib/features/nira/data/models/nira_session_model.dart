// data/models/nira_session_model.dart
// API response model for NIRA session (snake_case from backend View).

class NiraSessionModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime lastActiveAt;
  final String? summary;

  const NiraSessionModel({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.lastActiveAt,
    this.summary,
  });

  factory NiraSessionModel.fromJson(Map<String, dynamic> json) {
    return NiraSessionModel(
      id: _parseId(json['_id']),
      userId: _parseId(json['user_id']),
      startTime: _parseDateTime(json['start_time']),
      endTime: json['end_time'] != null ? _parseDateTime(json['end_time']) : null,
      lastActiveAt: _parseDateTime(json['last_active_at']),
      summary: json['summary'] as String?,
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
