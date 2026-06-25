import 'package:flutter/material.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';
import 'package:fly/features/user_profile/presentation/widgets/profile_card.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const _purple = Color(0xFF6C4EE4);

class _Session {
  final String id;
  final String mhpName;
  final String mhpPicture;
  final String specialty;
  final String preference;
  final String status;
  final DateTime startAt;
  final int amountINR;
  final String meetLink;

  _Session({
    required this.id,
    required this.mhpName,
    required this.mhpPicture,
    required this.specialty,
    required this.preference,
    required this.status,
    required this.startAt,
    required this.amountINR,
    required this.meetLink,
  });

  factory _Session.fromMap(Map<String, dynamic> m) => _Session(
        id: m['id']?.toString() ?? '',
        mhpName: m['mhp_name']?.toString() ?? 'MHP',
        mhpPicture: m['mhp_picture']?.toString() ?? '',
        specialty: m['specialty']?.toString() ?? '',
        preference: m['preference']?.toString() ?? '',
        status: m['status']?.toString() ?? '',
        startAt: (DateTime.tryParse(m['start_at']?.toString() ?? '') ??
            DateTime.now()).toLocal(),
        amountINR: (m['amount_inr'] as num?)?.toInt() ?? 0,
        meetLink: m['meet_link']?.toString() ?? '',
      );
}

class UserManageSessionsScreen extends StatefulWidget {
  const UserManageSessionsScreen({super.key});

  @override
  State<UserManageSessionsScreen> createState() =>
      _UserManageSessionsScreenState();
}

class _UserManageSessionsScreenState extends State<UserManageSessionsScreen>
    with SingleTickerProviderStateMixin {
  final _ds = UserSettingsRemoteDataSource();
  late TabController _tabCtrl;

  List<_Session> _upcoming = [];
  List<_Session> _completed = [];
  List<_Session> _cancelled = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _ds.getSessions(status: 'upcoming'),
        _ds.getSessions(status: 'completed'),
        _ds.getSessions(status: 'cancelled'),
      ]);
      _upcoming = (results[0]).map(_Session.fromMap).toList();
      _completed = (results[1]).map(_Session.fromMap).toList();
      _cancelled = (results[2]).map(_Session.fromMap).toList();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _cancel(_Session session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Session'),
        content: const Text('Are you sure you want to cancel this session?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _ds.cancelSession(session.id);
      setState(() {
        _upcoming.removeWhere((s) => s.id == session.id);
        _cancelled.insert(0, session);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m$period';
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text('Manage Sessions',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
          bottom: TabBar(
            controller: _tabCtrl,
            labelColor: _purple,
            unselectedLabelColor: Colors.black45,
            indicatorColor: _purple,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _sessionList(_upcoming, 'upcoming'),
                  _sessionList(_completed, 'completed'),
                  _sessionList(_cancelled, 'cancelled'),
                ],
              ),
      ),
    );
  }

  Widget _sessionList(List<_Session> sessions, String tab) {
    if (sessions.isEmpty) {
      return const Center(
          child: Text('No sessions',
              style: TextStyle(color: Colors.black45)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (_, i) => _sessionCard(sessions[i], tab),
    );
  }

  Future<void> _launchMeet(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _sessionCard(_Session s, String tab) {
    final statusColor = tab == 'upcoming'
        ? _purple
        : tab == 'completed'
            ? Colors.green
            : Colors.red;

    final statusLabel =
        tab == 'upcoming' ? 'Upcoming' : tab == 'completed' ? 'Completed' : 'Cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                imagePath: ProfilePictureHelper.getProfilePictureUrl(
                    s.mhpPicture),
                size: 56,
                dense: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WELLNESS SESSION WITH:',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                            letterSpacing: 0.5)),
                    Text(s.mhpName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    if (s.specialty.isNotEmpty)
                      Text(s.specialty,
                          style: const TextStyle(
                              color: _purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (s.preference == 'video')
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam_outlined,
                      color: _purple, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.calendar_month_outlined,
                  size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Text(_formatDate(s.startAt),
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54)),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•',
                      style: TextStyle(color: Colors.black45))),
              Icon(Icons.access_time_outlined,
                  size: 14, color: Colors.black45),
              const SizedBox(width: 2),
              Text(_formatTime(s.startAt),
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54)),
            ],
          ),
          if (tab == 'cancelled') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.videocam_outlined,
                        color: Colors.red, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('REFUND STATUS',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                              letterSpacing: 0.5)),
                      Text('₹${s.amountINR} · Refund Initiated',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const Text('Expected in 5-7 business days',
                          style: TextStyle(
                              color: Colors.black45, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          if (tab == 'upcoming')
            _UpcomingSessionActions(
              session: s,
              onCancel: () => _cancel(s),
              onJoin: s.meetLink.isNotEmpty ? () => _launchMeet(s.meetLink) : null,
            )
          else if (tab == 'completed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.bookSession),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: _purple),
                  ),
                  elevation: 0,
                ),
                child: const Text('Rebook session',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(AppRoutes.bookSession),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    child: const Text('Rebook Session',
                        style: TextStyle(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.discoverMhps),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: _purple),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Find MHP',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _UpcomingSessionActions extends StatelessWidget {
  final _Session session;
  final VoidCallback onCancel;
  final VoidCallback? onJoin;

  const _UpcomingSessionActions({
    required this.session,
    required this.onCancel,
    this.onJoin,
  });

  bool get _isImminent {
    final diff = session.startAt.difference(DateTime.now());
    return diff.inMinutes >= 0 && diff.inMinutes <= 60;
  }

  bool get _isStartingSoon {
    final diff = session.startAt.difference(DateTime.now());
    return diff.inMinutes >= 0 && diff.inMinutes <= 15;
  }

  String get _countdownLabel {
    final diff = session.startAt.difference(DateTime.now());
    if (diff.inMinutes <= 0) return 'Starting now';
    if (diff.inMinutes < 60) return 'Starts in ${diff.inMinutes}m';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = onJoin != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isImminent && hasLink) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isStartingSoon
                  ? const Color(0xFFFFF3E0)
                  : const Color(0xFFEDE9FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _isStartingSoon ? Icons.alarm_on : Icons.access_time,
                  size: 16,
                  color: _isStartingSoon ? Colors.orange.shade700 : _purple,
                ),
                const SizedBox(width: 6),
                Text(
                  _countdownLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        _isStartingSoon ? Colors.orange.shade700 : _purple,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (hasLink) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.videocam_outlined,
                  size: 18, color: Colors.white),
              label: const Text(
                'Join Session',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'Lexend'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.toNamed(AppRoutes.bookSession),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: _purple),
                  ),
                ),
                child: const Text('Reschedule',
                    style: TextStyle(
                        color: _purple, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
