import 'package:flutter/material.dart';
import 'package:fly/features/home/model/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final PageController _pageController = PageController();

  List<String> _selectedImages = [];
  String? _selectedVideo;
  List<String> _pollOptions = [];

  int _currentPage = 0;

  void _addPollOption() {
    setState(() {
      _pollOptions.add('');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() {
    if (_textController.text.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedVideo == null &&
        _pollOptions.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final newPost = Post(
      id: '', // Will be set by backend when post is created
      profileUrl: "https://i.pravatar.cc/150?img=99", // mock
      username: "You",
      timestamp: "just now",
      tagIconUrl: "",
      text: _textController.text,
      mediaUrl:
          _selectedVideo ??
          (_selectedImages.isNotEmpty ? _selectedImages[0] : ""),
      isVideo: _selectedVideo != null,
      likes: 0,
      comments: 0,
      views: 0,
      pollOptions: _pollOptions.where((e) => e.trim().isNotEmpty).toList(),
    );

    Navigator.pop(context, newPost); // return new Post to caller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
            ),

            // Images preview with PageView + dots
            if (_selectedImages.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                      },
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _selectedImages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == i ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Video preview
            if (_selectedVideo != null)
              Stack(
                children: [
                  Container(
                    height: 250,
                    color: Colors.black12,
                    child: Center(
                      child: Text("Video preview here: $_selectedVideo"),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() => _selectedVideo = null);
                        },
                      ),
                    ),
                  ),
                ],
              ),

            // Poll editor
            if (_pollOptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Poll Options:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._pollOptions.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              _pollOptions[i] = val;
                            },
                            decoration: InputDecoration(
                              hintText: "Option ${i + 1}",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _pollOptions.removeAt(i));
                          },
                        ),
                      ],
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addPollOption,
                    icon: const Icon(Icons.add),
                    label: const Text("Add option"),
                  ),
                ],
              ),
          ],
        ),
      ),

      // Bottom bar to attach media/poll
      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                setState(() {
                  if (_selectedVideo == null) {
                    _selectedImages.add(
                      "https://picsum.photos/400/300?random=${_selectedImages.length}",
                    );
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                setState(() {
                  if (_selectedImages.isEmpty) {
                    _selectedVideo =
                        "https://sample-videos.com/video123/mp4/480/asdasdas.mp4";
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.poll),
              onPressed: () {
                setState(() {
                  _pollOptions = ["", ""];
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
