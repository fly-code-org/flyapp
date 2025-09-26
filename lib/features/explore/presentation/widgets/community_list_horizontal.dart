import 'package:flutter/material.dart';
import 'package:fly/features/start_quiz/widgets/community_card.dart';

class CommunityListHorizontal extends StatelessWidget {
  const CommunityListHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock list of communities (replace with API data later)
    final List<Map<String, dynamic>> communities = [
      {
        "profilePicUrl": "https://picsum.photos/200",
        "communityName": "Tech Enthusiasts",
        "communityId": "@tech",
        "followerCount": 1200,
      },
      {
        "profilePicUrl": "https://picsum.photos/201",
        "communityName": "Art & Creativity",
        "communityId": "@artlife",
        "followerCount": 850,
      },
      {
        "profilePicUrl": "https://picsum.photos/202",
        "communityName": "Fitness Freaks",
        "communityId": "@fit",
        "followerCount": 430,
      },
      {
        "profilePicUrl": "https://picsum.photos/203",
        "communityName": "Book Lovers",
        "communityId": "@books",
        "followerCount": 970,
      },
      // 👉 Add up to 10 communities here
    ];

    return SizedBox(
      height: 150, // fixed height for horizontal scroll
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: communities.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final community = communities[index];
          return SizedBox(
            width: 160, // control card width
            child: CommunityCard(
              profilePicUrl: community["profilePicUrl"],
              communityName: community["communityName"],
              communityId: community["communityId"],
              followerCount: community["followerCount"],
              onJoin: () {
                debugPrint("Joined ${community["communityName"]}");
              },
            ),
          );
        },
      ),
    );
  }
}
