import 'package:flutter/material.dart';

/// Corner radius for MHP and community logos (rounded square — not circular like feed users).
const double kSquareEntityAvatarRadius = 8;

/// Network image in a rounded square. Use for MHP list items and community logos app-wide.
class SquareEntityAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData placeholderIcon;

  const SquareEntityAvatar({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.placeholderIcon = Icons.person_outline,
  });

  static bool _isNetworkUrl(String s) {
    final t = s.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim() ?? '';
    final hasNetwork = raw.isNotEmpty && _isNetworkUrl(raw);
    return ClipRRect(
      borderRadius: BorderRadius.circular(kSquareEntityAvatarRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: hasNetwork
            ? Image.network(
                raw,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.42,
                        height: size * 0.42,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Icon(
        placeholderIcon,
        color: Colors.grey.shade600,
        size: size * 0.45,
      ),
    );
  }
}
