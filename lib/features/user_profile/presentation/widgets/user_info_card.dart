import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  final String bio;
  final String location;
  final String date;

  const UserInfo({
    super.key,
    required this.userId,
    required this.bio,
    required this.location,
    required this.date,
  });

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Color(0xFF855DFC)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User ID
        Text(
          '@$userId',
          style: const TextStyle(
            fontSize: 22, // bigger font
            fontWeight: FontWeight.bold,
            color: Colors.black87, // make sure it's visible
            fontFamily: 'Lexend',
          ),
        ),
        const SizedBox(height: 12),

        // Info rows
        if (bio.isNotEmpty) _infoRow(Icons.person_outline, bio),
        if (bio.isNotEmpty) const SizedBox(height: 8),
        if (location.isNotEmpty) _infoRow(Icons.location_on_outlined, location),
        if (location.isNotEmpty) const SizedBox(height: 8),
        if (date.isNotEmpty) _infoRow(Icons.calendar_today_outlined, date),
      ],
    );
  }
}
