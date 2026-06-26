import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditCommunityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditCommunityButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // grey background
          borderRadius: BorderRadius.circular(50), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icon/edit.svg', width: 20, height: 20),
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
