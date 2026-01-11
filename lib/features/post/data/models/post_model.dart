// data/models/post_model.dart
import '../../domain/entities/post.dart';

// Helper function to parse DateTime from various formats
DateTime _parseDateTime(dynamic dateValue) {
  if (dateValue == null) {
    return DateTime.now();
  }
  
  if (dateValue is String) {
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      // Try parsing as ISO 8601 with timezone
      try {
        return DateTime.parse(dateValue.replaceAll('Z', '+00:00'));
      } catch (e2) {
        print('⚠️ [POST MODEL] Failed to parse date: $dateValue, using current time');
        return DateTime.now();
      }
    }
  }
  
  if (dateValue is int) {
    // Unix timestamp in seconds or milliseconds
    if (dateValue > 1000000000000) {
      // Milliseconds
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      // Seconds
      return DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
    }
  }
  
  if (dateValue is Map) {
    // MongoDB date format: {"$date": timestamp_ms}
    if (dateValue.containsKey('\$date')) {
      final timestamp = dateValue['\$date'];
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
  }
  
  print('⚠️ [POST MODEL] Unknown date format: $dateValue (${dateValue.runtimeType}), using current time');
  return DateTime.now();
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    super.communityId,
    required super.tagId,
    super.content,
    super.attachments = const [],
    super.poll,
    super.likes = const [],
    super.likeCount = 0,
    super.commentCount = 0,
    super.bookmarkedBy = const [],
    super.bookmarkCount = 0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse attachments
    final attachmentsList = <AttachmentModel>[];
    if (json['attachments'] != null && json['attachments'] is List) {
      for (var item in json['attachments'] as List) {
        if (item is Map<String, dynamic>) {
          attachmentsList.add(AttachmentModel.fromJson(item));
        }
      }
    }

    // Parse poll
    PollModel? pollModel;
    if (json['poll'] != null && json['poll'] is Map<String, dynamic>) {
      pollModel = PollModel.fromJson(json['poll'] as Map<String, dynamic>);
    }

    // Parse likes (UUIDs)
    final likesList = <String>[];
    if (json['likes'] != null && json['likes'] is List) {
      for (var item in json['likes']) {
        if (item != null) {
          likesList.add(item.toString());
        }
      }
    }

    // Parse bookmarkedBy (UUIDs)
    final bookmarkedByList = <String>[];
    if (json['bookmarked_by'] != null && json['bookmarked_by'] is List) {
      for (var item in json['bookmarked_by']) {
        if (item != null) {
          bookmarkedByList.add(item.toString());
        }
      }
    }

    // Handle both 'id' and '_id' fields (MongoDB might return '_id')
    final postId = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    
    return PostModel(
      id: postId,
      authorId: json['author_id']?.toString() ?? '',
      communityId: json['community_id']?.toString(),
      tagId: (json['tag_id'] is int) 
          ? json['tag_id'] as int 
          : (json['tag_id'] is num) 
              ? (json['tag_id'] as num).toInt()
              : (json['tag_id'] is String) 
                  ? int.tryParse(json['tag_id'] as String) ?? 0 
                  : 0,
      content: json['content'] as String?,
      attachments: attachmentsList,
      poll: pollModel,
      likes: likesList,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      bookmarkedBy: bookmarkedByList,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'community_id': communityId,
      'tag_id': tagId,
      'content': content,
      'attachments': attachments.map((a) => (a as AttachmentModel).toJson()).toList(),
      'poll': poll != null ? (poll as PollModel).toJson() : null,
      'likes': likes,
      'like_count': likeCount,
      'comment_count': commentCount,
      'bookmarked_by': bookmarkedBy,
      'bookmark_count': bookmarkCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AttachmentModel extends Attachment {
  const AttachmentModel({
    required super.type,
    required super.url,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}

class PollModel extends Poll {
  const PollModel({
    required super.question,
    required super.options,
    required super.expiresAt,
    required super.createdAt,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = <PollOptionModel>[];
    if (json['options'] != null && json['options'] is List) {
      for (var item in json['options'] as List) {
        if (item is Map<String, dynamic>) {
          optionsList.add(PollOptionModel.fromJson(item));
        }
      }
    }

    return PollModel(
      question: json['question'] as String? ?? '',
      options: optionsList,
      expiresAt: _parseDateTime(json['expires_at']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((o) => (o as PollOptionModel).toJson()).toList(),
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PollOptionModel extends PollOption {
  const PollOptionModel({
    required super.optionId,
    required super.text,
    super.votes = const [],
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    final votesList = <String>[];
    if (json['votes'] != null && json['votes'] is List) {
      for (var item in json['votes']) {
        if (item != null) {
          votesList.add(item.toString());
        }
      }
    }

    return PollOptionModel(
      optionId: json['option_id']?.toString() ?? '',
      text: json['text'] as String? ?? '',
      votes: votesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'text': text,
      'votes': votes,
    };
  }
}



