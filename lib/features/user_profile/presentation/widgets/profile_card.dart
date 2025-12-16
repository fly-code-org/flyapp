import 'package:flutter/material.dart';
import '../../../../core/utils/avatar_generator.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../core/network/api_client.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath; // can be asset or network
  final double size;
  final bool showEditIcon;
  final String? userId; // Optional: for generating avatar if imagePath is empty

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.showEditIcon = false,
    this.userId,
  });

  String _getAvatarUrl() {
    print('🔍 [AVATAR] _getAvatarUrl called with imagePath: "$imagePath", userId: "$userId"');
    
    // If imagePath is provided and is a valid URL, use it
    if (imagePath.isNotEmpty && imagePath.startsWith('http')) {
      print('✅ [AVATAR] Using provided imagePath: $imagePath');
      return imagePath;
    }
    
    // Try to get userId from JWT if not provided
    String? effectiveUserId = userId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      print('🔍 [AVATAR] userId not provided, trying to extract from JWT...');
      try {
        final token = ApiClient.getAuthToken();
        if (token != null && token.isNotEmpty) {
          effectiveUserId = JwtDecoder.getUserId(token);
          print('✅ [AVATAR] Extracted userId from JWT: $effectiveUserId');
        } else {
          print('⚠️ [AVATAR] No token available');
        }
      } catch (e) {
        print('⚠️ [AVATAR] Could not extract userId from token: $e');
      }
    }
    
    // Generate avatar from userId if available
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      final avatarUrl = AvatarGenerator.generateFromUserId(effectiveUserId);
      print('🎨 [AVATAR] Generated avatar URL: $avatarUrl');
      return avatarUrl;
    }
    
    // Fallback to default asset
    print('⚠️ [AVATAR] No userId available, using default asset');
    return 'assets/images/mydp.JPG';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _getAvatarUrl();
    final isNetworkImage = avatarUrl.startsWith("http");
    final isAssetImage = avatarUrl.startsWith("assets/");
    
    print('🖼️ [AVATAR] Building avatar with URL: $avatarUrl');
    print('🖼️ [AVATAR] isNetworkImage: $isNetworkImage, isAssetImage: $isAssetImage');
    
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              // Beautiful gradient background matching app's purple theme
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF855DFC).withOpacity(0.15), // Light purple
                  const Color(0xFFA68CFC).withOpacity(0.25), // Lighter purple
                ],
              ),
            ),
            child: ClipOval(
              child: isNetworkImage
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ [AVATAR] Network image failed, trying fallback');
                        // If network image fails, try generated avatar
                        final fallbackUrl = userId != null && userId!.isNotEmpty
                            ? AvatarGenerator.generateFromUserId(userId!)
                            : 'assets/images/mydp.JPG';
                        print('🔄 [AVATAR] Fallback URL: $fallbackUrl');
                        if (fallbackUrl.startsWith('http')) {
                          return Image.network(
                            fallbackUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ [AVATAR] Generated avatar also failed, using default asset');
                              return Image.asset('assets/images/mydp.JPG', fit: BoxFit.cover);
                            },
                          );
                        } else {
                          return Image.asset(fallbackUrl, fit: BoxFit.cover);
                        }
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ [AVATAR] Asset image failed, generating avatar');
                        // If asset fails, generate avatar
                        final fallbackUrl = userId != null && userId!.isNotEmpty
                            ? AvatarGenerator.generateFromUserId(userId!)
                            : AvatarGenerator.generateFromEmail('user@flyapp.in');
                        print('🔄 [AVATAR] Generated avatar URL: $fallbackUrl');
                        return Image.network(
                          fallbackUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ [AVATAR] Generated avatar failed, using default');
                            return Image.asset('assets/images/mydp.JPG', fit: BoxFit.cover);
                          },
                        );
                      },
                    ),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: const Icon(Icons.edit, size: 18, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
