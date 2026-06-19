import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/home/presentation/views/post_detail_screen.dart';
import 'package:fly/features/post/domain/entities/post.dart';
import 'package:fly/features/post/domain/usecases/get_posts_by_community.dart';
import 'package:fly/features/post/presentation/utils/post_converter.dart';

/// Activities tab: posts in MHP's community, tappable to full post detail.
class MhpActivitiesSection extends StatefulWidget {
  final String? communityId;

  const MhpActivitiesSection({super.key, this.communityId});

  @override
  State<MhpActivitiesSection> createState() => _MhpActivitiesSectionState();
}

class _MhpActivitiesSectionState extends State<MhpActivitiesSection> {
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MhpActivitiesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.communityId != widget.communityId) _load();
  }

  Future<void> _load() async {
    if (widget.communityId == null || widget.communityId!.isEmpty) {
      setState(() {
        _posts = [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await sl<GetPostsByCommunity>().call(widget.communityId!);
      if (!mounted) return;
      setState(() {
        _posts = posts;
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

  void _openDetail(Post domainPost) {
    final uiPost = PostConverter.toUIPost(domainPost);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: uiPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF855DFC))),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
            child: Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12))),
      );
    }
    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No posts in your community yet',
            style: TextStyle(fontFamily: 'Lexend', color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = _posts[index];
        final attachment = post.attachments.isNotEmpty ? post.attachments.first : null;
        final url = attachment?.url;
        final isVideo = attachment?.type == 'video';

        Widget thumb;
        if (url != null && url.isNotEmpty) {
          final fullUrl = url.startsWith('http') ? url : 'https://cdn.flyapp.in$url';
          thumb = Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: fullUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) =>
                    Container(color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
              if (isVideo)
                const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 28),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  isVideo ? Icons.videocam : Icons.photo,
                  color: Colors.white,
                  size: 16,
                  shadows: const [
                    Shadow(offset: Offset(0, 1), blurRadius: 3,
                        color: Colors.black45)
                  ],
                ),
              ),
            ],
          );
        } else {
          thumb = Container(
            color: Colors.grey[200],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  post.content ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _openDetail(post),
          child: thumb,
        );
      },
    );
  }
}
