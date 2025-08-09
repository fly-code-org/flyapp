import 'package:flutter/material.dart';

class EmailVerificationText extends StatelessWidget {
  const EmailVerificationText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Email Verification",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black, // or Colors.white if on dark background
          ),
        ),
        SizedBox(height: 8),
        Text(
          "For your security, we require a 4-digit One Time Code for quick verification for a safe and secure experience.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
