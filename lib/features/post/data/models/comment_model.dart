// data/models/comment_model.dart
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    super.parentCommentId,
    required super.userId,
    required super.text,
    super.likeCount,
    super.likes,
    super.replyCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Handle UUID format from backend (could be string or binary)
    String parseId(dynamic id) {
      if (id is String) return id;
      if (id is Map && id.containsKey('\$oid')) return id['\$oid'] as String;
      if (id is Map && id.containsKey('_id')) {
        final idValue = id['_id'];
        if (idValue is Map && idValue.containsKey('\$oid')) {
          return idValue['\$oid'] as String;
        }
      }
      return id.toString();
    }

    // Handle DateTime format from backend
    DateTime parseDateTime(dynamic date) {
      if (date is String) {
        return DateTime.parse(date).toLocal();
      }
      if (date is Map && date.containsKey('\$date')) {
        final dateValue = date['\$date'];
        if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue).toLocal();
        }
        if (dateValue is String) {
          return DateTime.parse(dateValue).toLocal();
        }
      }
      if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date).toLocal();
      }
      throw FormatException('Invalid date format: $date');
    }

    // Handle likes array - could be null, empty array, or array of UUIDs
    List<String> parseLikes(dynamic likes) {
      if (likes == null) return [];
      if (likes is List) {
        return likes.map((like) => parseId(like)).toList();
      }
      return [];
    }

    // Handle like_count - could be int or NumberLong
    int parseLikeCount(dynamic count) {
      if (count is int) return count;
      if (count is Map && count.containsKey('\$numberLong')) {
        return int.parse(count['\$numberLong'] as String);
      }
      return 0;
    }

    // Handle reply_count - could be int or NumberLong
    int parseReplyCount(dynamic count) {
      if (count is int) return count;
      if (count is Map && count.containsKey('\$numberLong')) {
        return int.parse(count['\$numberLong'] as String);
      }
      return 0;
    }

    return CommentModel(
      id: parseId(json['_id'] ?? json['id']),
      postId: parseId(json['post_id']),
      parentCommentId: json['parent_comment_id'] != null
          ? parseId(json['parent_comment_id'])
          : null,
      userId: parseId(json['user_id']),
      text: json['text'] as String? ?? '',
      likeCount: parseLikeCount(json['like_count'] ?? 0),
      likes: parseLikes(json['likes']),
      replyCount: parseReplyCount(json['reply_count'] ?? 0),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'user_id': userId,
      'text': text,
      'like_count': likeCount,
      'likes': likes,
      'reply_count': replyCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
