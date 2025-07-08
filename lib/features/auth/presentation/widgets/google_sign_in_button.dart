import 'package:flutter/material.dart'; // For SVG logo

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322,
      height: 53,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Logo SVG
            Image.asset(
              'assets/icon/google.png',
              height: 22,
              width: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Google',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
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
