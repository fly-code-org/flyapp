import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconShape { circular, square }

class SocialTagHorizontal extends StatelessWidget {
  final String categoryLabel;
  final String imagePath;
  final String rightText;
  final VoidCallback? onTap;
  final IconShape iconShape;
  final bool isFollowed; // New parameter to indicate if tag is followed

  const SocialTagHorizontal({
    super.key,
    required this.categoryLabel,
    required this.imagePath,
    required this.rightText,
    this.onTap,
    this.iconShape = IconShape.circular,
    this.isFollowed = false, // Default to not followed
  });

  bool get isSvg => imagePath.trim().toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      width: 32,
      height: 32,
      color: Colors.white,
      child: isSvg
          ? SvgPicture.asset(imagePath.trim(), fit: BoxFit.cover)
          : Image.asset(imagePath.trim(), fit: BoxFit.cover),
    );

    if (iconShape == IconShape.circular) {
      icon = ClipOval(child: icon);
    } else {
      icon = ClipRRect(borderRadius: BorderRadius.circular(4), child: icon);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowed ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: iconShape == IconShape.circular
              ? BorderRadius.circular(30)
              : BorderRadius.circular(10),
          border: isFollowed
              ? Border.all(color: Colors.blue.shade300, width: 1.5)
              : null,
          boxShadow: isFollowed
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              rightText,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
