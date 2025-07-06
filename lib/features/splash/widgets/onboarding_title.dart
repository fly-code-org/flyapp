import 'package:flutter/material.dart';

class OnboardingTitle extends StatelessWidget {
  final double dragPosition;

  const OnboardingTitle({super.key, required this.dragPosition});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.45,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: dragPosition < 0.3 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Center(
          child: Text(
            "first love yourself",
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
