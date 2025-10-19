import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath; // can be asset or network
  final double size;
  final bool showEditIcon;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 150,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 5),
              image: DecorationImage(
                image: imagePath.startsWith("http")
                    ? NetworkImage(imagePath) as ImageProvider
                    : AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: const Icon(Icons.edit, size: 18, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
