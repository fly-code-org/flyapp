import 'package:flutter/material.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/features/community/domain/entities/explore_search_result.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

/// "Discover Mental Health Professionals" card: full-bleed photo with the name
/// overlaid at the top and a "Book Session" pill at the bottom.
///
/// Tapping the card opens the MHP's profile; the button jumps to booking.
/// Used by both the Explore carousel and the "See All" grid.
class MhpDiscoverCard extends StatelessWidget {
  final ExploreSearchMhp mhp;

  /// When non-null, constrains the card width (carousel). Grid passes null and
  /// lets the parent (GridView) size it.
  final double? width;

  const MhpDiscoverCard({super.key, required this.mhp, this.width});

  void _openProfile() {
    Get.toNamed(AppRoutes.mhpProfile, arguments: {'userId': mhp.userId});
  }

  void _bookSession() {
    Get.toNamed(AppRoutes.bookSession, arguments: {'mhpId': mhp.userId});
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = mhp.picturePath.isNotEmpty
        ? ProfilePictureHelper.getProfilePictureUrl(mhp.picturePath)
        : '';

    final card = GestureDetector(
      onTap: _openProfile,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo (or gradient placeholder).
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (ctx, child, progress) =>
                    progress == null ? child : _placeholder(),
              )
            else
              _placeholder(),

            // Top + bottom scrim so white text and the pill stay legible.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x66000000),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // Name (top-left).
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Text(
                mhp.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 4, color: Color(0x99000000)),
                  ],
                ),
              ),
            ),

            // Book Session pill (bottom-right).
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: _bookSession,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1E1E1E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Book Session',
                        style: TextStyle(
                          
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6C6D4), Color(0xFFE9A8BC)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 56, color: Colors.white70),
      ),
    );
  }
}
