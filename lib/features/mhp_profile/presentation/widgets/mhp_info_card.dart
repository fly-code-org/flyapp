import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final String userName;
  final String bio;
  final String location;
  final String yearsOfExp;
  final int yearsOfExperience;
  final bool certifiedMhp;
  final String degreePath;

  const UserInfo({
    super.key,
    required this.userName,
    required this.bio,
    required this.location,
    required this.yearsOfExp,
    this.yearsOfExperience = 0,
    this.certifiedMhp = false,
    this.degreePath = '',
  });

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF855DFC)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expLabel = yearsOfExperience > 0
        ? '$yearsOfExperience ${yearsOfExperience == 1 ? 'year' : 'years'} of experience'
        : (yearsOfExp.isNotEmpty ? yearsOfExp : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display name — no "@" prefix
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Lexend',
          ),
        ),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              fontFamily: 'Lexend',
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (expLabel != null) _infoRow(Icons.schedule_outlined, expLabel),
        if (certifiedMhp || degreePath.isNotEmpty) _infoRow(Icons.verified_outlined, 'Certifications'),
        if (location.isNotEmpty) _infoRow(Icons.location_on_outlined, location),
      ],
    );
  }
}
