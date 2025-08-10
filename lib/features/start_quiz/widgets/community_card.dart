import 'package:flutter/material.dart';

class CommunityCard extends StatelessWidget {
  final String profilePicUrl;
  final String communityName;
  final String communityId;
  final int followerCount;
  final VoidCallback? onJoin;

  const CommunityCard({
    super.key,
    required this.profilePicUrl,
    required this.communityName,
    required this.communityId,
    required this.followerCount,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // important to avoid stretching vertically
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  profilePicUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: onJoin,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            communityName,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            communityId,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$followerCount followers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
