import 'package:flutter/material.dart';

class ShareProfile extends StatelessWidget {
  final VoidCallback onPressed;

  const ShareProfile({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF855DFC), // purple
              Color(0xFFD16AFF), // pinkish purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.connect_without_contact_outlined,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              "Share Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
