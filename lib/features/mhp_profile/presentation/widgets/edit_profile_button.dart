import 'package:flutter/material.dart';

class EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditProfileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // grey background
          borderRadius: BorderRadius.circular(50), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.person_add_alt_outlined,
              size: 20,
              color: Color(0xFF855DFC),
            ),
            SizedBox(width: 8),
            Text(
              "Edit Profile",
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
