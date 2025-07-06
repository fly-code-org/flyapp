import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "Created with 🤍 in India",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
