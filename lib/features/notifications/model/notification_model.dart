class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.metadata = const {},
    this.isRead = false,
  });

  String get meetLink {
    final v = metadata['meet_link'];
    return v is String ? v.trim() : '';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'];
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String,
      message: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: meta is Map<String, dynamic> ? meta : const {},
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
