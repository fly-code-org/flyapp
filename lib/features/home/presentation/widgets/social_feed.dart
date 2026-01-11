import 'package:flutter/material.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';

class SocialFeed extends StatelessWidget {
  final bool isSocialTab;
  final List<Post> posts;

  const SocialFeed({super.key, required this.posts, this.isSocialTab = true});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      // Optimize list rendering with cacheExtent
      cacheExtent: 500.0,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // Use a more stable key based on post content
        final postKey = post.mediaUrl ?? post.text ?? '${post.timestamp}_$index';
        return SocialPost(
          key: ValueKey('post_${postKey}_$index'),
          post: post,
          isSocialTab: isSocialTab,
        );
      },
    );
  }
}
