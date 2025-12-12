import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconShape { circular, square }

class SocialTag extends StatelessWidget {
  final String categoryLabel;
  final String imageUrl;
  final String rightText;
  final VoidCallback? onTap;
  final IconShape iconShape;
  final bool isSelected;

  const SocialTag({
    super.key,
    required this.categoryLabel,
    required this.imageUrl,
    required this.rightText,
    this.onTap,
    this.iconShape = IconShape.circular,
    this.isSelected = false,
  });

  bool get isSvg => imageUrl.trim().toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      width: 32,
      height: 32,
      color: Colors.white,
      child: isSvg
          ? SvgPicture.network(
              imageUrl.trim(),
              fit: BoxFit.cover,
            )
          : Image.network(
              imageUrl.trim(),
              fit: BoxFit.cover,
            ),
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
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: iconShape == IconShape.circular
              ? BorderRadius.circular(30)
              : BorderRadius.circular(10), // smaller radius for square shape
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
