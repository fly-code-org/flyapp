import 'package:flutter/material.dart';

class EditCommunityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditCommunityButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // grey background
          borderRadius: BorderRadius.circular(50), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit, size: 20, color: Color(0xFF855DFC)),
            SizedBox(width: 8),
            Text(
              "Edit Community",
              style: TextStyle(
                color: Color(0xFF855DFC),
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
