import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/post/domain/entities/post.dart';
import 'package:fly/features/post/domain/usecases/get_posts_by_community.dart';

/// Activities tab: posts in MHP's community.
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
        child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
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
        final url = post.attachments.isNotEmpty ? post.attachments.first.url : null;
        return Container(
          color: Colors.grey[200],
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url.startsWith('http') ? url : 'https://cdn.flyapp.in$url',
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Text(
                    post.content ?? '',
                    style: const TextStyle(fontSize: 10),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        );
      },
    );
  }
}
