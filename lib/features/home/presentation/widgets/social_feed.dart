import 'package:flutter/material.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';

class SocialFeed extends StatelessWidget {
  final bool isSocialTab; // true for Social, false for Support

  const SocialFeed({super.key, this.isSocialTab = true});

  @override
  Widget build(BuildContext context) {
    final posts = [
      Post(
        profileUrl: "https://i.pravatar.cc/150?img=1",
        username: "john_doe",
        timestamp: "1h",
        tagIconUrl: "https://cdn-icons-png.flaticon.com/512/25/25694.png",
        text:
            "This is a sample post with some text content. It may be long and will show see more if overflowed.",
        mediaUrl: "https://picsum.photos/400/300",
        isVideo: false,
        likes: 23,
        comments: 5,
        views: 102,
      ),
      Post(
        profileUrl: "https://i.pravatar.cc/150?img=2",
        username: "jane_smith",
        timestamp: "2h",
        tagIconUrl: "https://cdn-icons-png.flaticon.com/512/25/25694.png",
        text: "Check out this cool video post!",
        mediaUrl: "https://sample-videos.com/video123/mp4/480/asdasdas.mp4",
        isVideo: true,
        likes: 56,
        comments: 12,
        views: 500,
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.zero, // remove padding
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return SocialPost(
          post: posts[index],
          isSocialTab: isSocialTab, // pass dynamic tab info
        );
      },
    );
  }
}
