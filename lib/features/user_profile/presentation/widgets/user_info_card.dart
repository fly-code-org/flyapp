import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  final String bio;
  final String location;
  final String date;
  final int reputation;

  const UserInfo({
    super.key,
    required this.userId,
    required this.bio,
    required this.location,
    required this.date,
    this.reputation = 1,
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
        // Username + reputation badge on the same row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '@$userId',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ReputationBadge(reputation: reputation),
          ],
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

class _ReputationBadge extends StatelessWidget {
  final int reputation;

  const _ReputationBadge({required this.reputation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPrivilegeSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF855DFC), Color(0xFFA68CFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond_outlined, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              '$reputation',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivilegeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PrivilegeSheet(reputation: reputation),
    );
  }
}

class _PrivilegeSheet extends StatelessWidget {
  final int reputation;

  const _PrivilegeSheet({required this.reputation});

  @override
  Widget build(BuildContext context) {
    final privileges = [
      _Privilege(points: 1, label: 'Create text posts', icon: Icons.edit_outlined),
      _Privilege(points: 15, label: 'Upvote content', icon: Icons.thumb_up_outlined),
      _Privilege(points: 50, label: 'Comment on posts', icon: Icons.chat_bubble_outline),
      _Privilege(points: 150, label: 'Flag content for review', icon: Icons.flag_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.diamond_outlined, color: Color(0xFF855DFC), size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Reputation: $reputation',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Earn reputation by creating posts, getting upvotes, and completing daily quizzes.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Privileges',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 12),
          ...privileges.map((p) => _buildPrivilegeRow(p)),
        ],
      ),
    );
  }

  Widget _buildPrivilegeRow(_Privilege p) {
    final unlocked = reputation >= p.points;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            p.icon,
            size: 20,
            color: unlocked ? const Color(0xFF855DFC) : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.label,
              style: TextStyle(
                fontSize: 14,
                color: unlocked ? Colors.black87 : Colors.grey.shade500,
                fontFamily: 'Lexend',
                decoration: unlocked ? null : TextDecoration.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFF855DFC).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${p.points} rep',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: unlocked ? const Color(0xFF855DFC) : Colors.grey.shade500,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            unlocked ? Icons.check_circle : Icons.lock_outline,
            size: 18,
            color: unlocked ? Colors.green : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _Privilege {
  final int points;
  final String label;
  final IconData icon;
  const _Privilege({required this.points, required this.label, required this.icon});
}
