import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/home/presentation/widgets/community_tabs.dart';
import 'package:fly/features/home/presentation/views/creat_post_screen.dart';
import 'package:fly/features/home/presentation/widgets/social_feed.dart';
import 'package:fly/features/home/model/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int streakCount = 2;
  final int _currentIndex = 0;
  int activeTabIndex = 0;

  // Keep posts in state so we can add new ones
  List<Post> posts = [
    Post(
      profileUrl: "https://i.pravatar.cc/150?img=1",
      username: "john_doe",
      timestamp: "1h",
      tagIconUrl: "",
      text: "This is a sample post with some text content.",
      mediaUrls: [
        "https://picsum.photos/400/300",
        "https://picsum.photos/400/301",
      ],
      isVideo: false,
      likes: 23,
      comments: 5,
      views: 102,
    ),
    Post(
      profileUrl: "https://i.pravatar.cc/150?img=2",
      username: "jane_smith",
      timestamp: "2h",
      tagIconUrl: "",
      text: "Check out this cool video post!",
      mediaUrl: "https://sample-videos.com/video123/mp4/480/asdasdas.mp4",
      isVideo: true,
      likes: 56,
      comments: 12,
      views: 500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          strokeWidth: 1.5,
                          dashPattern: const [6, 3],
                          color: Colors.grey,
                          radius: const Radius.circular(30),
                          padding: EdgeInsets.zero,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "🪽$streakCount Streaks",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/images/fly_home.svg",
                        height: 32,
                        semanticsLabel: 'Fly logo',
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Upgrade",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  SocialSupportTabs(
                    key: const ValueKey("tabs"),
                    onTabChanged: (index) {
                      setState(() {
                        activeTabIndex = index;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Feed
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: SocialFeed(
                        posts: posts,
                        isSocialTab: activeTabIndex == 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Button
            Positioned(
              bottom: 30,
              right: 16,
              child: Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () async {
                    final newPost = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) => const CreatePostScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              final tween = Tween(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );

                    if (newPost != null && newPost is Post) {
                      setState(() {
                        posts.insert(0, newPost);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Create Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
