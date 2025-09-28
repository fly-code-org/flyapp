import 'package:flutter/material.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';

class SocialFeed extends StatelessWidget {
  final bool isSocialTab;
  final List<Post> posts;

  const SocialFeed({super.key, required this.posts, this.isSocialTab = true});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return SocialPost(post: posts[index], isSocialTab: isSocialTab);
      },
    );
  }
}
