import 'package:flutter/material.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/core/widgets/square_entity_avatar.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MHPSquare extends StatelessWidget {
  final Community? community;

  const MHPSquare({super.key, this.community});

  @override
  Widget build(BuildContext context) {
    final hasCommunity = community != null;
    final title = hasCommunity ? community!.name : 'Create your community';
    final imagePath = hasCommunity && community!.logoPath.isNotEmpty
        ? ProfilePictureHelper.getProfilePictureUrl(community!.logoPath)
        : 'assets/images/community_demo.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey[400],
                  endIndent: 10,
                ),
              ),
              const Text(
                "MHP's Square",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  fontFamily: 'Lexend',
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey[400],
                  indent: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (hasCommunity) {
              Get.toNamed(AppRoutes.CommunitySupportProfile, arguments: {'communityId': community!.id});
            } else {
              Get.toNamed(AppRoutes.CreateSupportCommunity);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(kSquareEntityAvatarRadius),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: imagePath.startsWith('http')
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.groups_outlined,
                                color: Colors.grey.shade600,
                                size: 26,
                              ),
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.groups_outlined,
                                color: Colors.grey.shade600,
                                size: 26,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lexend',
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
