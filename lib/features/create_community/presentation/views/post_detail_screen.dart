import 'package:flutter/material.dart';
import 'package:fly/features/create_community/model/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Detail")),
      body: Center(
        child: post.type == "text"
            ? Text(post.content, style: const TextStyle(fontSize: 20))
            : Image.network(post.content),
      ),
    );
  }
}
