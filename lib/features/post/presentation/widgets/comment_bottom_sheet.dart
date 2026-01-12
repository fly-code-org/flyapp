// presentation/widgets/comment_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/utils/avatar_generator.dart';
import 'package:fly/core/network/api_client.dart';
import '../controllers/comment_controller.dart';
import '../../domain/entities/comment.dart';
import 'package:intl/intl.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentController _commentController = sl<CommentController>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToCommentId; // Track which comment we're replying to
  String? _replyingToUserId; // Track the user ID we're replying to

  bool _isLoading = false;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    // Fetch comments when bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadComments();
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _commentController.fetchCommentsByPostId(widget.postId);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _comments = _commentController.getCommentsForPost(widget.postId);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePostComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _commentController.createCommentEntry(
      postId: widget.postId,
      parentCommentId: _replyingToCommentId,
      text: text,
    );

    if (success && mounted) {
      _textController.clear();
      _replyingToCommentId = null;
      _replyingToUserId = null;
      // Reload comments to show the new one
      await _loadComments();
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleReplyToComment(String commentId, String userId) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUserId = userId;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserId = null;
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String? _getCurrentUserId() {
    try {
      final token = ApiClient.getAuthToken();
      if (token != null && token.isNotEmpty) {
        return JwtDecoder.getUserId(token);
      }
    } catch (e) {
      print('⚠️ [COMMENT] Error getting current user ID: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              // Scrollable content
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Comments List
                  Expanded(
                    child: _isLoading && _comments.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Builder(
                            builder: (context) {
                              final topLevelComments = _comments
                                  .where((c) => c.parentCommentId == null)
                                  .toList();

                              if (topLevelComments.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: _replyingToCommentId != null
                                      ? 140
                                      : 100,
                                ),
                                itemCount: topLevelComments.length,
                                itemBuilder: (context, index) {
                                  final comment = topLevelComments[index];
                                  final replies = _comments
                                      .where(
                                        (c) => c.parentCommentId == comment.id,
                                      )
                                      .toList();

                                  return _buildCommentItem(comment, replies, 0);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
              // Fixed input area at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reply indicator
                    if (_replyingToCommentId != null &&
                        _replyingToUserId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Replying to ${_replyingToUserId!.substring(0, 8)}...',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _cancelReply,
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    // Input area
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  AvatarGenerator.generateFromUserId(
                                    _getCurrentUserId() ?? 'anonymous',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Text input
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText: _replyingToCommentId != null
                                        ? 'Add a reply...'
                                        : 'Add a comment...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.newline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Post button
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _textController,
                                builder: (context, value, child) {
                                  final hasText = value.text.trim().isNotEmpty;
                                  return IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: hasText && !_isLoading
                                          ? const Color(0xFF855DFC)
                                          : Colors.grey,
                                    ),
                                    onPressed: hasText && !_isLoading
                                        ? _handlePostComment
                                        : null,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(
    Comment comment,
    List<Comment> replies,
    int indentLevel,
  ) {
    final isReply = indentLevel > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment
        Padding(
          padding: EdgeInsets.only(
            left: indentLevel * 32.0, // Indent replies
            top: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: isReply ? 16 : 20,
                backgroundImage: NetworkImage(
                  AvatarGenerator.generateFromUserId(comment.userId),
                ),
              ),
              const SizedBox(width: 12),
              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username and text
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                        ),
                        children: [
                          TextSpan(
                            text: '${comment.userId.substring(0, 8)}... ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: comment.text),
                        ],
                      ),
                      maxLines: null,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 4),
                    // Timestamp and reply button
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (comment.replyCount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () =>
                              _handleReplyToComment(comment.id, comment.userId),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Replies (flattened with indent)
        ...replies.map(
          (reply) => _buildCommentItem(reply, [], indentLevel + 1),
        ),
      ],
    );
  }
}
