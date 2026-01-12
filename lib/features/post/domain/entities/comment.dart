// domain/entities/comment.dart
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String? parentCommentId; // null = top-level comment; otherwise it's a reply
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
        userId,
        text,
        likeCount,
        likes,
        replyCount,
        createdAt,
        updatedAt,
      ];
}
