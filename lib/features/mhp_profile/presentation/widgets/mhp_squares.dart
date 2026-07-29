import 'package:flutter/material.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

const _purple = Color(0xFF855DFC);

class MHPSquare extends StatelessWidget {
  final Community? community;

  const MHPSquare({super.key, this.community});

  @override
  Widget build(BuildContext context) {
    final hasCommunity = community != null;

    return GestureDetector(
      onTap: () {
        if (hasCommunity) {
          Get.toNamed(AppRoutes.CommunityWellnessProfile,
              arguments: {'communityId': community!.id});
        } else {
          Get.toNamed(AppRoutes.CreateWellnessCommunity);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_purple, Color(0xFF6A3DE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              // Community logo or placeholder icon
              _CommunityLogo(community: community),
              const SizedBox(width: 12),
              // Name + member count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "MHP's Square",
                      style: TextStyle(
                        
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCommunity ? community!.name : 'No community yet',
                      style: const TextStyle(
                        
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasCommunity &&
                        community!.members != null &&
                        community!.members!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        '${community!.members!.length} members',
                        style: TextStyle(
                          
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Action chip
              _Chip(label: hasCommunity ? 'Visit' : 'Create'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityLogo extends StatelessWidget {
  final Community? community;
  const _CommunityLogo({this.community});

  @override
  Widget build(BuildContext context) {
    final hasCommunity = community != null;

    if (!hasCommunity || community!.logoPath.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.groups_outlined, color: Colors.white, size: 22),
      );
    }

    final url = ProfilePictureHelper.getProfilePictureUrl(community!.logoPath);

    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: url.startsWith('http')
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.groups_outlined,
                      color: Colors.white, size: 22),
                ),
              )
            : Image.asset(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.groups_outlined,
                      color: Colors.white, size: 22),
                ),
              ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _purple,
        ),
      ),
    );
  }
}
