import 'package:flutter/material.dart';

class GradientTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color>? gradientColors;

  const GradientTextButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Center( // Centered horizontally
      child: GestureDetector(
        onTap: onTap,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: gradientColors ??
                const [
                  Color(0xFF8A56AC),
                  Color(0xFF6A3BA0),
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          blendMode: BlendMode.srcIn,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lexend',
              // decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
