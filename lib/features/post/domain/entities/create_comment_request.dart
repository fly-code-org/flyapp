// domain/entities/create_comment_request.dart
import 'package:equatable/equatable.dart';

class CreateCommentRequest extends Equatable {
  final String postId;
  final String? parentCommentId; // null = top-level comment; otherwise it's a reply
  final String text;

  const CreateCommentRequest({
    required this.postId,
    this.parentCommentId,
    required this.text,
  });

  @override
  List<Object?> get props => [postId, parentCommentId, text];
}
