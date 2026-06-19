import 'package:flutter/material.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const _purple = Color(0xFF855DFC);

class UpcomingSessionBanner extends StatelessWidget {
  final Map<String, dynamic> session;

  const UpcomingSessionBanner({super.key, required this.session});

  DateTime get _startAt =>
      DateTime.tryParse(session['start_at']?.toString() ?? '') ?? DateTime.now();

  String get _mhpName => session['mhp_name']?.toString() ?? 'your therapist';

  String get _meetLink => session['meet_link']?.toString() ?? '';

  String get _specialty => session['specialty']?.toString() ?? '';

  bool get _isImminent {
    final diff = _startAt.difference(DateTime.now());
    return diff.inMinutes >= 0 && diff.inMinutes <= 60;
  }

  bool get _isStartingSoon {
    final diff = _startAt.difference(DateTime.now());
    return diff.inMinutes >= 0 && diff.inMinutes <= 15;
  }

  String get _countdownLabel {
    final diff = _startAt.difference(DateTime.now());
    if (diff.inMinutes <= 0) return 'Starting now';
    if (diff.inMinutes < 60) return 'Starts in ${diff.inMinutes}m';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (m == 0) return 'Starts in ${h}h';
    return 'Starts in ${h}h ${m}m';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  Future<void> _joinSession() async {
    final uri = Uri.tryParse(_meetLink);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = _meetLink.isNotEmpty;
    final imminent = _isImminent;
    final soon = _isStartingSoon;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.UserManageSessions),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: soon
                ? [const Color(0xFFFF6B35), const Color(0xFFFF8C5A)]
                : [_purple, const Color(0xFF6A3DE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (soon ? Colors.orange : _purple).withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  soon ? Icons.alarm_on_rounded : Icons.videocam_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imminent ? _countdownLabel : 'Upcoming session',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _mhpName,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_specialty.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        '${_formatDate(_startAt)} · ${_formatTime(_startAt)}',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 1),
                      Text(
                        '${_formatDate(_startAt)} · ${_formatTime(_startAt)}',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (hasLink && imminent)
                _ActionChip(label: 'Join', onTap: _joinSession)
              else
                _ActionChip(
                  label: 'View',
                  onTap: () => Get.toNamed(AppRoutes.UserManageSessions),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _purple,
          ),
        ),
      ),
    );
  }
}
