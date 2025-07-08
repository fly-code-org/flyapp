import 'package:flutter/material.dart';

class AlreadyMemberText extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;

  const AlreadyMemberText({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check which part to highlight based on text content
    final isLogin = text.toLowerCase().contains("login");

    // Split text intelligently
    final prefix = isLogin
        ? "Already a fly member? "
        : "Not logged in? ";
    final actionText = isLogin ? "Login here" : "Signup here";

    return SizedBox(
      width: 377,
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: prefix,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: actionText,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
