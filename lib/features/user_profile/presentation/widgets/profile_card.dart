import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/avatar_generator.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/network/api_client.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath; // can be asset or network
  final double size;
  final bool showEditIcon;
  final String? userId; // Optional: for generating avatar if imagePath is empty

  /// Inline avatars (e.g. feed): fixed size, no outer frame; avoids [Center]
  /// expanding inside [Row] and matches compact list layout.
  final bool dense;

  /// When true, clip as a rounded square (support / community style) instead of a circle.
  final bool useRoundedSquare;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.showEditIcon = false,
    this.userId,
    this.dense = false,
    this.useRoundedSquare = false,
  });

  String _getAvatarUrl() {
    print('🔍 [AVATAR] _getAvatarUrl called with imagePath: "$imagePath", userId: "$userId"');
    
    // If imagePath is provided, process it through ProfilePictureHelper
    if (imagePath.isNotEmpty) {
      final processedPath = ProfilePictureHelper.getProfilePictureUrl(imagePath);
      print('✅ [AVATAR] Processed imagePath: $processedPath');
      return processedPath;
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
    final isLocalAsset = ProfilePictureHelper.isLocalAsset(avatarUrl);
    final isNetworkImage = avatarUrl.startsWith("http");
    final isAssetImage = avatarUrl.startsWith("assets/") || isLocalAsset;

    print('🖼️ [AVATAR] Building avatar with URL: $avatarUrl');
    print(
      '🖼️ [AVATAR] isLocalAsset: $isLocalAsset, isNetworkImage: $isNetworkImage, isAssetImage: $isAssetImage',
    );

    final child = _buildAvatarWidget(
      avatarUrl,
      isLocalAsset,
      isNetworkImage,
      isAssetImage,
    );
    final squareRadius = BorderRadius.circular(
      (size * 0.2).clamp(6.0, 10.0),
    );
    final inner = useRoundedSquare
        ? ClipRRect(
            borderRadius: squareRadius,
            child: SizedBox(
              width: size,
              height: size,
              child: child,
            ),
          )
        : ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: child,
            ),
          );

    if (dense) {
      return SizedBox(width: size, height: size, child: inner);
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: useRoundedSquare ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: useRoundedSquare ? squareRadius : null,
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
            child: inner,
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

  Widget _buildAvatarWidget(String avatarUrl, bool isLocalAsset, bool isNetworkImage, bool isAssetImage) {
    // Handle local assets (e.g., /assets/profile_2.svg)
    if (isLocalAsset) {
      final assetPath = ProfilePictureHelper.getAssetPath(avatarUrl);
      final isSvg = assetPath.toLowerCase().endsWith('.svg');
      
      if (isSvg) {
        return SvgPicture.asset(
          assetPath,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error, stackTrace) {
            print('❌ [AVATAR] SVG asset failed: $assetPath');
            return _getFallbackAvatar();
          },
        );
      } else {
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ [AVATAR] Asset image failed: $assetPath');
            return _getFallbackAvatar();
          },
        );
      }
    }
    
    // Handle network images
    if (isNetworkImage) {
      final isSvg = avatarUrl.toLowerCase().endsWith('.svg');
      
      if (isSvg) {
        // Wrap SVG loading in a try-catch-like widget structure
        // Use errorBuilder to catch SVG parsing errors
        return SvgPicture.network(
          avatarUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error, stackTrace) {
            print('❌ [AVATAR] Network SVG failed (error: $error), using fallback');
            print('📚 [AVATAR] Stack trace: $stackTrace');
            // Return fallback immediately on any SVG error
            return _getFallbackAvatar();
          },
        );
      } else {
        return Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ [AVATAR] Network image failed, trying fallback');
            return _getFallbackAvatar();
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
        );
      }
    }
    
    // Handle regular asset images (assets/...)
    if (isAssetImage) {
      return Image.asset(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ [AVATAR] Asset image failed, generating avatar');
          return _getFallbackAvatar();
        },
      );
    }
    
    // Fallback
    return _getFallbackAvatar();
  }

  Widget _getFallbackAvatar() {
    // Try generated avatar if userId is available
    if (userId != null && userId!.isNotEmpty) {
      final fallbackUrl = AvatarGenerator.generateFromUserId(userId!);
      if (fallbackUrl.startsWith('http')) {
        return Image.network(
          fallbackUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/mydp.JPG', fit: BoxFit.cover);
          },
        );
      }
    }
    // Default asset
    return Image.asset('assets/images/mydp.JPG', fit: BoxFit.cover);
  }
}
