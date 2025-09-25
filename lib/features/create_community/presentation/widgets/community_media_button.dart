import 'package:flutter/material.dart';

class MediaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MediaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF855DFC), // Purple
              Color(0xFFA68CFC), // Lighter purple
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.perm_media, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Media",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
