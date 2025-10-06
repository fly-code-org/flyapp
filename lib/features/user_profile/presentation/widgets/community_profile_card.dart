import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommunityProfileCard extends StatelessWidget {
  final String communityType; // "social" or "support"
  final String title;
  final int members;
  final String description; // new field
  final String tagIconPath; // SVG asset path
  final String profileImagePath; // PNG/JPG asset path

  const CommunityProfileCard({
    super.key,
    required this.communityType,
    required this.title,
    required this.members,
    required this.description,
    required this.tagIconPath,
    required this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSocial = communityType.toLowerCase() == "social";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image
        ClipRRect(
          borderRadius: isSocial
              ? BorderRadius.circular(50) // circular for social
              : BorderRadius.circular(8), // square for support
          child: Image.asset(
            profileImagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Title + members + description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$members members",
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // SVG Tag Icon
        SvgPicture.asset(
          tagIconPath,
          width: 28,
          height: 28,
          placeholderBuilder: (context) =>
              Container(width: 28, height: 28, color: Colors.grey.shade200),
        ),
      ],
    );
  }
}
