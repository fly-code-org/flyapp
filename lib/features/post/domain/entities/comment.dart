// domain/entities/comment.dart
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String? parentCommentId; // null = top-level; always points to root (max 1 level deep)
  final String? mentionedUserId; // user being @mentioned in this reply
  final String userId;
  final String text;
  final int likeCount;
  final List<String> likes;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.postId,
    this.parentCommentId,
    this.mentionedUserId,
    required this.userId,
    required this.text,
    this.likeCount = 0,
    this.likes = const [],
    this.replyCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        parentCommentId,
        mentionedUserId,
        userId,
        text,
        likeCount,
        likes,
        replyCount,
        createdAt,
        updatedAt,
      ];
}
