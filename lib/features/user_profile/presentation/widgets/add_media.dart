import 'package:flutter/material.dart';

class AddMediaWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const AddMediaWidget({
    super.key,
    required this.onTap,
    this.text = "Add Media",
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // 👈 left side of screen
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent, // 👈 transparent background
            borderRadius: BorderRadius.circular(50), // pill shape
            border: Border.all(
              color: Colors.grey, // gradient alternative: purple-pink
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // shrink to content
            children: [
              const Icon(Icons.upload_file, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
