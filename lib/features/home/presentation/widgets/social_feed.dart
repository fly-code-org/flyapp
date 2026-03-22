import 'package:flutter/material.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';

class SocialFeed extends StatelessWidget {
  final bool isSocialTab;
  final List<Post> posts;
  final Function(Post)? onPostUpdated;
  final VoidCallback? onRefreshNeeded;
  final ScrollController? scrollController;
  final bool isLoadingMore;

  const SocialFeed({
    super.key,
    required this.posts,
    this.isSocialTab = true,
    this.onPostUpdated,
    this.onRefreshNeeded,
    this.scrollController,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.zero,
      cacheExtent: 500.0,
      itemCount: posts.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (isLoadingMore && index == posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final post = posts[index];
        final postKey = post.id.isNotEmpty ? post.id : '${post.timestamp}_$index';
        return SocialPost(
          key: ValueKey('post_${postKey}_$index'),
          post: post,
          isSocialTab: isSocialTab,
          onPostUpdated: onPostUpdated,
          onRefreshNeeded: onRefreshNeeded,
        );
      },
    );
  }
}
