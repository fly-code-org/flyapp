// presentation/widgets/comment_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/utils/avatar_generator.dart';
import 'package:fly/core/network/api_client.dart';
import '../controllers/comment_controller.dart';
import '../services/user_profile_service.dart';
import '../../domain/entities/comment.dart';
import 'package:intl/intl.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommentAdded;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    this.onCommentAdded,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentController _commentController = sl<CommentController>();
  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Reply state
  String? _replyingToCommentId; // always the root comment id
  String? _replyingToUsername;  // display name of the person being @mentioned

  bool _isLoading = false;
  List<Comment> _topLevelComments = [];
  Map<String, String> _usernames = {};

  // Tracks which root comments have their replies visible
  final Set<String> _expandedCommentIds = {};
  // Lazily loaded replies per root comment id
  final Map<String, List<Comment>> _repliesByCommentId = {};
  // Tracks which comment ids are currently loading replies
  final Set<String> _loadingReplies = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadComments();
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    try {
      await _commentController.fetchCommentsByPostId(widget.postId);
      if (!mounted) return;

      final allComments = _commentController.getCommentsForPost(widget.postId);
      final topLevel = allComments.where((c) => c.parentCommentId == null).toList();

      final uniqueUserIds = allComments.map((c) => c.userId).toSet().toList();
      final profiles = await _userProfileService.getUserProfiles(uniqueUserIds);
      final usernames = <String, String>{};
      for (final entry in profiles.entries) {
        final name = entry.value['username'];
        if (name != null && name.isNotEmpty) {
          usernames[entry.key] = name;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _topLevelComments = topLevel;
          _usernames = usernames;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReplies(Comment comment) async {
    final id = comment.id;
    if (_expandedCommentIds.contains(id)) {
      setState(() => _expandedCommentIds.remove(id));
      return;
    }

    // Already fetched — just expand
    if (_repliesByCommentId.containsKey(id)) {
      setState(() => _expandedCommentIds.add(id));
      return;
    }

    setState(() => _loadingReplies.add(id));

    final replies = await _commentController.fetchRepliesForComment(id);

    // Fetch usernames for any new commenters
    final newUserIds = replies
        .map((r) => r.userId)
        .where((uid) => !_usernames.containsKey(uid))
        .toSet()
        .toList();
    if (newUserIds.isNotEmpty) {
      final profiles = await _userProfileService.getUserProfiles(newUserIds);
      for (final entry in profiles.entries) {
        final name = entry.value['username'];
        if (name != null && name.isNotEmpty) {
          _usernames[entry.key] = name;
        }
      }
    }

    if (mounted) {
      setState(() {
        _repliesByCommentId[id] = replies;
        _expandedCommentIds.add(id);
        _loadingReplies.remove(id);
      });
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

    setState(() => _isLoading = true);

    final success = await _commentController.createCommentEntry(
      postId: widget.postId,
      parentCommentId: _replyingToCommentId,
      text: text,
    );

    if (success && mounted) {
      _textController.clear();
      final wasReply = _replyingToCommentId != null;
      final replyTargetId = _replyingToCommentId;
      _replyingToCommentId = null;
      _replyingToUsername = null;
      if (widget.onCommentAdded != null) widget.onCommentAdded!();

      // Reload top-level list and (if we replied) refresh that thread
      await _loadComments();
      if (wasReply && replyTargetId != null) {
        _repliesByCommentId.remove(replyTargetId);
        _expandedCommentIds.add(replyTargetId);
        await _toggleReplies(
          _topLevelComments.firstWhere(
            (c) => c.id == replyTargetId,
            orElse: () => _topLevelComments.first,
          ),
        );
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Tap "Reply" on any comment or reply — always threads under the root comment
  void _handleReplyToComment(Comment tappedComment) {
    // If tapping a reply (has a parent), thread under its root instead
    final rootId = tappedComment.parentCommentId ?? tappedComment.id;
    final mentionUsername =
        _usernames[tappedComment.userId] ?? tappedComment.userId.substring(0, 8);

    setState(() {
      _replyingToCommentId = rootId;
      _replyingToUsername = mentionUsername;
      // Pre-fill with @mention so the user can start typing immediately
      _textController.text = '@$mentionUsername ';
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
      _textController.clear();
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 7) return DateFormat('MMM d').format(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String? _getCurrentUserId() {
    try {
      final token = ApiClient.getAuthToken();
      if (token != null && token.isNotEmpty) return JwtDecoder.getUserId(token);
    } catch (_) {}
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
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            
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
                  // Comments list
                  Expanded(
                    child: _isLoading && _topLevelComments.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _topLevelComments.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    'No comments yet',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: _replyingToCommentId != null ? 140 : 100,
                                ),
                                itemCount: _topLevelComments.length,
                                itemBuilder: (context, index) =>
                                    _buildRootComment(_topLevelComments[index]),
                              ),
                  ),
                ],
              ),
              // Fixed input at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reply indicator
                    if (_replyingToCommentId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Replying to @${_replyingToUsername ?? ''}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const Spacer(),
                            TextButton(onPressed: _cancelReply, child: const Text('Cancel')),
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
                          border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  AvatarGenerator.generateFromUserId(
                                    _getCurrentUserId() ?? 'anonymous',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                                    onPressed: hasText && !_isLoading ? _handlePostComment : null,
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

  Widget _buildRootComment(Comment comment) {
    final replies = _repliesByCommentId[comment.id] ?? [];
    final isExpanded = _expandedCommentIds.contains(comment.id);
    final isLoadingReplies = _loadingReplies.contains(comment.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(comment, isReply: false),
        // "View N replies" toggle or reply list
        if (comment.replyCount > 0 || replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 4, bottom: 2),
            child: isLoadingReplies
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: () => _toggleReplies(comment),
                    child: Text(
                      isExpanded
                          ? 'Hide replies'
                          : 'View ${comment.replyCount > 0 ? comment.replyCount : replies.length} ${(comment.replyCount == 1 && replies.length <= 1) ? 'reply' : 'replies'}',
                      style: const TextStyle(
                        color: Color(0xFF855DFC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        
                      ),
                    ),
                  ),
          ),
        // Expanded replies (1 level only)
        if (isExpanded)
          ...replies.map((reply) => _buildCommentTile(reply, isReply: true)),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, {required bool isReply}) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 44.0 : 0, top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundImage: NetworkImage(
              AvatarGenerator.generateFromUserId(comment.userId),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      
                    ),
                    children: [
                      TextSpan(
                        text: '${_usernames[comment.userId] ?? comment.userId.substring(0, 8)} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                  maxLines: null,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _handleReplyToComment(comment),
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
    );
  }
}
