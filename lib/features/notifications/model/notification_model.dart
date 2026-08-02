class ActorModel {
  final String userId;
  final String username;
  final String displayName;
  final String? picturePath;

  ActorModel({
    required this.userId,
    required this.username,
    required this.displayName,
    this.picturePath,
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    return ActorModel(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      picturePath: json['picture_path'] as String?,
    );
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final List<ActorModel> actors;
  final int actorCount;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.metadata = const {},
    this.actors = const [],
    this.actorCount = 0,
    this.isRead = false,
  });

  String get meetLink {
    final v = metadata['meet_link'];
    return v is String ? v.trim() : '';
  }

  String? get postId => metadata['post_id'] as String?;
  String? get commentId => metadata['comment_id'] as String?;
  String? get postThumbnail => metadata['post_thumbnail'] as String?;
  String? get tagName => metadata['tag_name'] as String?;

  bool get isSocialNotification {
    return type == 'post_like' ||
        type == 'post_comment' ||
        type == 'comment_reply' ||
        type == 'followed_tag_post';
  }

  String? get firstActorPicture {
    if (actors.isNotEmpty) {
      return actors.first.picturePath;
    }
    return null;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'];
    final actorsList = json['actors'] as List<dynamic>? ?? [];

    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String,
      message: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: meta is Map<String, dynamic> ? meta : const {},
      actors: actorsList
          .map((e) => ActorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      actorCount: json['actor_count'] as int? ?? 0,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
