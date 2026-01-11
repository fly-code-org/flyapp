// domain/entities/post.dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String authorId;
  final String? communityId; // Optional, can be derived from tag
  final int tagId; // Required: tag ID for the post
  final String? content;
  final List<Attachment> attachments;
  final Poll? poll;
  final List<String> likes;
  final int likeCount;
  final int commentCount;
  final List<String> bookmarkedBy;
  final int bookmarkCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.authorId,
    this.communityId,
    required this.tagId,
    this.content,
    this.attachments = const [],
    this.poll,
    this.likes = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkedBy = const [],
    this.bookmarkCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        communityId,
        tagId,
        content,
        attachments,
        poll,
        likes,
        likeCount,
        commentCount,
        bookmarkedBy,
        bookmarkCount,
        createdAt,
        updatedAt,
      ];
}

class Attachment extends Equatable {
  final String type; // "image" or "video"
  final String url;

  const Attachment({
    required this.type,
    required this.url,
  });

  @override
  List<Object?> get props => [type, url];
}

class Poll extends Equatable {
  final String question;
  final List<PollOption> options;
  final DateTime expiresAt;
  final DateTime createdAt;

  const Poll({
    required this.question,
    required this.options,
    required this.expiresAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [question, options, expiresAt, createdAt];
}

class PollOption extends Equatable {
  final String optionId;
  final String text;
  final List<String> votes;

  const PollOption({
    required this.optionId,
    required this.text,
    this.votes = const [],
  });

  @override
  List<Object?> get props => [optionId, text, votes];
}



