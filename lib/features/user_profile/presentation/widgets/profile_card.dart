import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/avatar_generator.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/network/api_client.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final bool showEditIcon;
  final String? userId;

  /// Inline avatars (e.g. feed): fixed size, no outer frame.
  final bool dense;

  /// When true, clip as a rounded square instead of a circle.
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
    if (imagePath.isNotEmpty) {
      return ProfilePictureHelper.getProfilePictureUrl(imagePath);
    }

    String? effectiveUserId = userId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      try {
        final token = ApiClient.getAuthToken();
        if (token != null && token.isNotEmpty) {
          effectiveUserId = JwtDecoder.getUserId(token);
        }
      } catch (_) {}
    }

    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      return AvatarGenerator.generateFromUserId(effectiveUserId);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _getAvatarUrl();
    final isLocalAsset = ProfilePictureHelper.isLocalAsset(avatarUrl);
    final isNetworkImage = avatarUrl.startsWith("http");
    final isAssetImage = avatarUrl.startsWith("assets/") || isLocalAsset;

    final child = _buildAvatarWidget(avatarUrl, isLocalAsset, isNetworkImage, isAssetImage);
    final squareRadius = BorderRadius.circular((size * 0.2).clamp(6.0, 10.0));
    final inner = useRoundedSquare
        ? ClipRRect(borderRadius: squareRadius, child: SizedBox(width: size, height: size, child: child))
        : ClipOval(child: SizedBox(width: size, height: size, child: child));

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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF855DFC).withOpacity(0.15),
                  const Color(0xFFA68CFC).withOpacity(0.25),
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
                child: SvgPicture.asset('assets/icon/edit.svg', width: 18, height: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8E0F0),
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: const Color(0xFF855DFC).withOpacity(0.4),
      ),
    );
  }

  Widget _buildAvatarWidget(String avatarUrl, bool isLocalAsset, bool isNetworkImage, bool isAssetImage) {
    if (avatarUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (isLocalAsset) {
      final assetPath = ProfilePictureHelper.getAssetPath(avatarUrl);
      final isSvg = assetPath.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.asset(
          assetPath,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _buildPlaceholder(),
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (isNetworkImage) {
      final isSvg = avatarUrl.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.network(
          avatarUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _buildPlaceholder(),
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(),
        errorWidget: (_, __, ___) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    }

    if (isAssetImage) {
      return Image.asset(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }
}
