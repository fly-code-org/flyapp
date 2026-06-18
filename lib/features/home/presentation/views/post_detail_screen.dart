import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/avatar_generator.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';
import 'package:fly/features/post/presentation/controllers/comment_controller.dart';
import 'package:fly/features/post/presentation/services/user_profile_service.dart';
import 'package:fly/features/post/domain/entities/comment.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommentController _commentController = sl<CommentController>();
  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  List<Comment> _comments = [];
  Map<String, String> _usernames = {};
  String? _replyingToCommentId;
  String? _replyingToUsername;

  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadComments());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      await _commentController.fetchCommentsByPostId(_post.id);
      if (!mounted) return;
      final comments = _commentController.getCommentsForPost(_post.id);
      final uniqueUserIds = comments.map((c) => c.userId).toSet().toList();
      final profiles = await _userProfileService.getUserProfiles(uniqueUserIds);
      final usernames = <String, String>{};
      for (final entry in profiles.entries) {
        final name = entry.value['username'];
        if (name != null && name.isNotEmpty) usernames[entry.key] = name;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _comments = comments;
          _usernames = usernames;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToComments() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
    _focusNode.requestFocus();
  }

  Future<void> _handlePostComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    final success = await _commentController.createCommentEntry(
      postId: _post.id,
      parentCommentId: _replyingToCommentId,
      text: text,
    );

    if (success && mounted) {
      _textController.clear();
      setState(() {
        _replyingToCommentId = null;
        _replyingToUsername = null;
        _isSubmitting = false;
        _post = _post.copyWith(comments: _post.comments + 1);
      });
      await _loadComments();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  void _handleReply(String commentId, String userId) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = _usernames[userId] ?? 'user';
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7) return DateFormat('MMM d').format(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  Widget _buildCommentItem(Comment comment, List<Comment> replies, int depth) {
    final username = _usernames[comment.userId] ?? 'user';
    final avatarUrl = AvatarGenerator.generateAvatarUrl(comment.userId);
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(comment.text, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Row(
                    children: [
                      Text(
                        _formatTimestamp(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _handleReply(comment.id, comment.userId),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Replies
                if (replies.isNotEmpty)
                  Column(
                    children: replies
                        .map((r) => _buildCommentItem(r, [], depth + 1))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topLevelComments =
        _comments.where((c) => c.parentCommentId == null).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Post card
                SliverToBoxAdapter(
                  child: SocialPost(
                    post: _post,
                    isDetailView: true,
                    onCommentButtonTap: _scrollToComments,
                    onPostUpdated: (updatedPost) {
                      if (mounted) setState(() => _post = updatedPost);
                    },
                  ),
                ),
                // Comments header
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_post.comments}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Comments list
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: _isLoading && _comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : topLevelComments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            child: Column(
                              children: topLevelComments.map((comment) {
                                final replies = _comments
                                    .where(
                                      (c) =>
                                          c.parentCommentId == comment.id,
                                    )
                                    .toList();
                                return _buildCommentItem(comment, replies, 0);
                              }).toList(),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Pinned comment input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyingToCommentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Text(
                          'Replying to $_replyingToUsername',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _cancelReply,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _handlePostComment,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSubmitting
                                ? Colors.grey[300]
                                : Colors.black,
                          ),
                          child: _isSubmitting
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
