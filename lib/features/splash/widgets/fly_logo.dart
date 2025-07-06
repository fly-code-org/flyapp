import 'package:flutter/material.dart';

class FlyLogo extends StatelessWidget {
  final double dragPosition;

  const FlyLogo({super.key, required this.dragPosition});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: dragPosition > 0.3 ? 50 : MediaQuery.of(context).size.height * 0.3,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/fly_logo.png',
          fit: BoxFit.none,
          height: 100,
        ),
      ),
    );
  }
}
