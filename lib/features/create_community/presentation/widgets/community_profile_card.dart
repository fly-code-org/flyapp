import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/widgets/square_entity_avatar.dart';

class CommunityProfileCard extends StatelessWidget {
  final String communityType; // "social" or "support"
  final String title;
  final int members;
  final String description;
  final String tagIconPath; // SVG asset path or empty for default
  final String profileImagePath; // asset path for fallback
  final String? profileImageUrl; // network URL (preferred if non-empty)

  const CommunityProfileCard({
    super.key,
    required this.communityType,
    required this.title,
    required this.members,
    required this.description,
    required this.tagIconPath,
    required this.profileImagePath,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image (network URL or asset) — rounded square for social + support
        ClipRRect(
          borderRadius: BorderRadius.circular(kSquareEntityAvatarRadius),
          child: SizedBox(
            width: 50,
            height: 50,
            child: profileImageUrl != null &&
                    profileImageUrl!.isNotEmpty &&
                    profileImageUrl!.startsWith('http')
                ? Image.network(
                    profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : Image.asset(
                    profileImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
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

        // SVG Tag Icon (asset or placeholder)
        tagIconPath.isNotEmpty
            ? SvgPicture.asset(
                tagIconPath,
                width: 28,
                height: 28,
                placeholderBuilder: (context) =>
                    Container(width: 28, height: 28, color: Colors.grey.shade200),
              )
            : Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.label_outline, size: 20),
              ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade300,
      child: const Icon(Icons.people, color: Colors.white),
    );
  }
}
