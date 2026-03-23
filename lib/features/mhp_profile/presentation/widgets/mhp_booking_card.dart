import 'package:flutter/material.dart';
import 'package:fly/features/user_profile/presentation/widgets/profile_card.dart';

/// Booking row on MHP Sessions tab (demo / future API).
enum MhpBookingCardStatus { confirmed, pending }

/// Light neutral surface (lighter than #D9D9D9 for softer cards).
const Color _cardBg = Color(0xFFF2F2F2);
const Color _purpleVideo = Color(0xFF855DFC);
const Color _statusConfirmedBg = Color(0xFFECF8F1);
const Color _statusConfirmedText = Color(0xFF7FC09C);
const Color _statusPendingBg = Color(0xFFFFF3E8);
const Color _statusPendingText = Color(0xFFEB833C);

/// Card: avatar + name, status pill, date/time, video CTA.
class MhpBookingCard extends StatelessWidget {
  final String fullName;
  /// Displayed as-is (include `@` if desired).
  final String username;
  final String? profileImagePath;
  final String? clientUserId;
  final MhpBookingCardStatus status;
  final String startTimeLabel;
  final String dateLabel;
  final VoidCallback? onVideoPressed;

  const MhpBookingCard({
    super.key,
    required this.fullName,
    required this.username,
    this.profileImagePath,
    this.clientUserId,
    required this.status,
    required this.startTimeLabel,
    required this.dateLabel,
    this.onVideoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                imagePath: profileImagePath ?? '',
                userId: clientUserId,
                size: 40,
                dense: true,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      username,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$startTimeLabel · $dateLabel',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    color: Colors.grey[900],
                  ),
                ),
              ),
              _VideoPill(onPressed: onVideoPressed),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final MhpBookingCardStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final confirmed = status == MhpBookingCardStatus.confirmed;
    final bg = confirmed ? _statusConfirmedBg : _statusPendingBg;
    final fg = confirmed ? _statusConfirmedText : _statusPendingText;
    final label = confirmed ? 'Confirmed' : 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: fg,
        ),
      ),
    );
  }
}

class _VideoPill extends StatelessWidget {
  final VoidCallback? onPressed;

  const _VideoPill({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _purpleVideo,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.videocam, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Video',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
