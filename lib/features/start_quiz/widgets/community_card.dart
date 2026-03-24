import 'package:flutter/material.dart';
import 'package:fly/core/widgets/square_entity_avatar.dart';

class CommunityCard extends StatelessWidget {
  final String profilePicUrl;
  final String communityName;
  final String communityId;
  final int followerCount;
  final VoidCallback? onJoin;
  final bool isSelected;

  const CommunityCard({
    super.key,
    required this.profilePicUrl,
    required this.communityName,
    required this.communityId,
    required this.followerCount,
    this.onJoin,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isSelected
            ? Border.all(color: Colors.blue, width: 2)
            : null,
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: isSelected ? Colors.blue.shade100 : Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquareEntityAvatar(
                imageUrl: profilePicUrl,
                size: 48,
                placeholderIcon: Icons.groups_outlined,
              ),
              Spacer(),
              TextButton(
                onPressed: onJoin,
                style: TextButton.styleFrom(
                  backgroundColor:
                      isSelected ? Colors.blue.shade100 : Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  isSelected ? 'Joined' : 'Join',
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              communityName,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$followerCount followers',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
