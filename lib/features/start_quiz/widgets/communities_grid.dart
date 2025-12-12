import 'package:flutter/material.dart';
import 'package:fly/features/start_quiz/widgets/community_card.dart';

class CommunitiesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> communities;
  final Set<String>? selectedCommunityIds;
  final Function(String)? onCommunityTap;

  const CommunitiesGrid({
    super.key,
    required this.communities,
    this.selectedCommunityIds,
    this.onCommunityTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.all(12),
      childAspectRatio: 1, // width : height ratio (0.75), tweak as needed
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: communities.map((community) {
        final communityId = community['communityId'] as String;
        final isSelected =
            selectedCommunityIds?.contains(communityId) ?? false;
        return CommunityCard(
          profilePicUrl: community['profilePicUrl'],
          communityName: community['communityName'],
          communityId: communityId,
          followerCount: community['followerCount'],
          isSelected: isSelected,
          onJoin: onCommunityTap != null
              ? () => onCommunityTap!(communityId)
              : null,
        );
      }).toList(),
    );
  }
}
