// core/widgets/safe_svg_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A safe wrapper around SvgPicture.asset that handles errors gracefully
/// This prevents crashes when SVG files contain unsupported elements
class SafeSvgIcon extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  const SafeSvgIcon({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return fallback ??
          Icon(
            Icons.tag,
            size: width ?? height ?? 20,
            color: Colors.grey,
          );
    }

    // Use errorBuilder to catch SVG parsing errors
    // Wrap in a Builder to ensure proper error context
    return Builder(
      builder: (context) {
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          // errorBuilder catches parsing errors and renders fallback
          errorBuilder: (context, error, stackTrace) {
            // Log the error for debugging but don't crash
            debugPrint('⚠️ [SAFE_SVG] Error loading SVG: $assetPath');
            debugPrint('   Error: $error');
            return fallback ??
                Icon(
                  Icons.tag,
                  size: width ?? height ?? 20,
                  color: Colors.grey,
                );
          },
          // placeholderBuilder shows while loading
          placeholderBuilder: (context) => fallback ??
              SizedBox(
                width: width ?? 20,
                height: height ?? 20,
                child: Icon(
                  Icons.tag,
                  size: (width ?? height ?? 20) * 0.8,
                  color: Colors.grey,
                ),
              ),
          semanticsLabel: 'Tag icon',
        );
      },
    );
  }
}
