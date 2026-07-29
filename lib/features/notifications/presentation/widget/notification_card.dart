import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const _purple = Color(0xFF855DFC);

  IconData _iconForType(String type) {
    switch (type) {
      case 'payment_success':
        return Icons.check_circle_outline;
      case 'session_booked':
        return Icons.calendar_today_outlined;
      case 'session_reminder':
        return Icons.alarm;
      case 'streak_lost':
        return Icons.local_fire_department_outlined;
      case 'streak_milestone':
        return Icons.emoji_events_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'payment_success':
        return Colors.green.shade600;
      case 'session_booked':
        return _purple;
      case 'session_reminder':
        return Colors.orange.shade700;
      case 'streak_lost':
        return Colors.red.shade400;
      case 'streak_milestone':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final iconColor = _colorForType(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF4F2FF) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForType(notification.type), color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  if (_isSessionType(notification.type) &&
                      notification.meetLink.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _JoinMeetChip(meetLink: notification.meetLink),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(notification.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSessionType(String type) =>
      type == 'session_booked' || type == 'session_reminder';

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _JoinMeetChip extends StatelessWidget {
  final String meetLink;
  const _JoinMeetChip({required this.meetLink});

  Future<void> _launch() async {
    final uri = Uri.tryParse(meetLink);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF855DFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_outlined, size: 14, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Join Session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
