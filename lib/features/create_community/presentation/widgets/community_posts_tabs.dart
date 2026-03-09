import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/home/model/post_model.dart' as ui_model;
import 'package:fly/features/home/presentation/widgets/social_feed.dart';
import 'package:fly/features/post/domain/entities/post.dart';
import 'package:fly/features/post/domain/usecases/get_posts_by_community.dart';
import 'package:fly/features/post/presentation/services/user_profile_service.dart';
import 'package:fly/features/post/presentation/utils/post_converter.dart';

/// New = newest first, Popular = most liked. Uses same SocialPost as home screen.
class CommunityPostsTabs extends StatefulWidget {
  final String communityId;

  const CommunityPostsTabs({super.key, required this.communityId});

  @override
  State<CommunityPostsTabs> createState() => _CommunityPostsTabsState();
}

class _CommunityPostsTabsState extends State<CommunityPostsTabs> {
  List<Post> _posts = [];
  Map<String, String> _authorProfileUrls = {};
  Map<String, String> _authorUsernames = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CommunityPostsTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.communityId != widget.communityId) _load();
  }

  Future<void> _load() async {
    if (widget.communityId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await sl<GetPostsByCommunity>().call(widget.communityId);
      if (!mounted) return;

      if (posts.isEmpty) {
        setState(() {
          _posts = [];
          _authorProfileUrls = {};
          _authorUsernames = {};
          _loading = false;
        });
        return;
      }

      final authorIds = posts.map((p) => p.authorId).toSet().toList();
      final userProfileService = UserProfileService();
      final authorProfiles = await userProfileService.getUserProfiles(authorIds);
      if (!mounted) return;

      final authorProfileUrls = <String, String>{};
      final authorUsernames = <String, String>{};
      for (var entry in authorProfiles.entries) {
        final userId = entry.key;
        final profile = entry.value;
        final usernameValue = profile['username'];
        String? username;
        if (usernameValue != null) {
          final s = usernameValue.toString().trim();
          username = s.isEmpty ? null : s;
        }
        final picturePath = profile['picture_path'];
        if (username != null && username.isNotEmpty) {
          authorUsernames[userId] = username;
        }
        if (picturePath != null && picturePath.toString().isNotEmpty) {
          authorProfileUrls[userId] = picturePath.toString();
        }
      }

      setState(() {
        _posts = posts;
        _authorProfileUrls = authorProfileUrls;
        _authorUsernames = authorUsernames;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Post> get _newPosts {
    final list = List<Post>.from(_posts);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Post> get _popularPosts {
    final list = List<Post>.from(_posts);
    list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    return list;
  }

  List<ui_model.Post> _toUIPosts(List<Post> apiPosts) {
    return PostConverter.toUIPosts(
      apiPosts,
      authorProfileUrls: _authorProfileUrls,
      authorUsernames: _authorUsernames,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF855DFC)),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!,
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      );
    }
    final uiNew = _toUIPosts(_newPosts);
    final uiPopular = _toUIPosts(_popularPosts);
    return TabBarView(
      children: [
        uiNew.isEmpty
            ? const Center(
                child: Text('No posts yet',
                    style: TextStyle(
                        fontFamily: 'Lexend', color: Colors.grey)),
              )
            : SocialFeed(
                posts: uiNew,
                isSocialTab: false,
              ),
        uiPopular.isEmpty
            ? const Center(
                child: Text('No posts yet',
                    style: TextStyle(
                        fontFamily: 'Lexend', color: Colors.grey)),
              )
            : SocialFeed(
                posts: uiPopular,
                isSocialTab: false,
              ),
      ],
    );
  }
}
