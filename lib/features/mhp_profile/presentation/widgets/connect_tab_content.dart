import 'package:flutter/material.dart';
import 'package:fly/core/config/config.dart';
import 'package:fly/core/config/fly_google_sign_in.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/error/exceptions.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/core/storage/pending_mhp_google_calendar_code.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_booking_card.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_mhp_booked_sessions.dart';
import 'package:fly/features/profile_creation/domain/usecases/link_mhp_google_calendar.dart';
import 'package:fly/features/profile_creation/domain/usecases/update_connect.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const _purple = Color(0xFF855DFC);
const _kGoogleCalendarReauthRequired = 'reauth_required';
const _bookedSessionsPageSize = 20;

DateTime _utcToIST(DateTime t) =>
    t.toUtc().add(const Duration(hours: 5, minutes: 30));

DateTime? _parseApiDate(dynamic v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

/// Connect tab: Your availability + bookings (sessions). Light purple UI.
class ConnectTabContent extends StatefulWidget {
  final List<Map<String, dynamic>> availableSlots;

  /// Passed from profile; will map to [MhpBookingCard] when integrated.
  final List<Map<String, dynamic>> appointments;

  /// Server-backed: MHP has linked Google Calendar (GET self profile).
  final bool googleCalendarConnected;

  /// `active` or [reauth_required] from server.
  final String? googleCalendarStatus;
  final VoidCallback? onSlotsUpdated;

  const ConnectTabContent({
    super.key,
    required this.availableSlots,
    required this.appointments,
    this.googleCalendarConnected = false,
    this.googleCalendarStatus,
    this.onSlotsUpdated,
  });

  @override
  State<ConnectTabContent> createState() => _ConnectTabContentState();
}

class _ConnectTabContentState extends State<ConnectTabContent> {
  bool _calendarLinkBusy = false;
  List<Map<String, dynamic>> _bookedSessions = [];
  bool _bookedSessionsLoading = false;
  bool _bookedSessionsLoadingMore = false;
  bool _bookedSessionsHasMore = false;
  int _bookedSessionsSkip = 0;
  String? _bookedSessionsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryDeferredCalendarLink();
      _loadBookedSessions(reset: true);
    });
  }

  Future<void> _loadBookedSessions({bool reset = false}) async {
    if (reset) {
      setState(() {
        _bookedSessionsSkip = 0;
        _bookedSessionsHasMore = true;
        _bookedSessionsError = null;
        _bookedSessionsLoading = true;
      });
    } else {
      if (_bookedSessionsLoadingMore ||
          !_bookedSessionsHasMore ||
          _bookedSessionsLoading) {
        return;
      }
      setState(() => _bookedSessionsLoadingMore = true);
    }
    try {
      await ApiClient.refreshToken();
      final skip = reset ? 0 : _bookedSessionsSkip;
      final page = await sl<GetMhpBookedSessions>()(
        skip: skip,
        limit: _bookedSessionsPageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _bookedSessions = List<Map<String, dynamic>>.from(page.items);
        } else {
          _bookedSessions = [..._bookedSessions, ...page.items];
        }
        _bookedSessionsSkip = _bookedSessions.length;
        _bookedSessionsHasMore = page.hasMore;
        _bookedSessionsLoading = false;
        _bookedSessionsLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bookedSessionsError = e.toString();
        _bookedSessionsLoading = false;
        _bookedSessionsLoadingMore = false;
      });
    }
  }

  Future<void> _openMeetLink(String raw) async {
    final url = raw.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildBookedSessionsSection() {
    if (_bookedSessionsLoading && _bookedSessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_bookedSessionsError != null && _bookedSessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Could not load bookings. Pull to refresh.',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 13,
            color: Colors.red.shade800,
          ),
        ),
      );
    }
    if (_bookedSessions.isEmpty) {
      return Text(
        'No sessions yet. Pending payments and confirmed bookings will appear here.',
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.3,
        ),
      );
    }
    final timeFmt = DateFormat('h:mm a');
    final dateFmt = DateFormat('MMM d, y');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._bookedSessions.map((item) {
          final start = _parseApiDate(item['start_at']);
          final end = _parseApiDate(item['end_at']);
          final display = (item['display_name'] as String?)?.trim() ?? 'Client';
          final un = (item['username'] as String?)?.trim() ?? '';
          final atName = un.isNotEmpty ? '@$un' : '@client';
          final seekerId = (item['seeker_user_id'] as String?)?.trim();
          final pic = item['picture_path'] as String?;
          final meetRaw = item['meet_link'];
          final meet = meetRaw is String ? meetRaw.trim() : '';
          final hasMeet = meet.isNotEmpty;
          final bs =
              (item['booking_status'] as String?)?.trim().toLowerCase() ??
              'confirmed';
          final isPending = bs == 'pending';
          String timeLabel = '—';
          String dateLabel = '—';
          if (start != null) {
            final ist = _utcToIST(start);
            dateLabel = dateFmt.format(ist);
            if (end != null) {
              timeLabel =
                  '${timeFmt.format(_utcToIST(start))} – ${timeFmt.format(_utcToIST(end))}';
            } else {
              timeLabel = timeFmt.format(ist);
            }
          }
          return MhpBookingCard(
            fullName: display,
            username: atName,
            profileImagePath: pic,
            clientUserId: seekerId,
            status: isPending
                ? MhpBookingCardStatus.pending
                : MhpBookingCardStatus.confirmed,
            startTimeLabel: timeLabel,
            dateLabel: dateLabel,
            onVideoPressed: !isPending && hasMeet
                ? () => _openMeetLink(meet)
                : null,
          );
        }),
        if (_bookedSessionsHasMore) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _bookedSessionsLoadingMore
                  ? null
                  : () => _loadBookedSessions(reset: false),
              child: _bookedSessionsLoadingMore
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Load more',
                      style: TextStyle(fontFamily: 'Lexend', color: _purple),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _tryDeferredCalendarLink() async {
    await ApiClient.refreshToken();
    final ok = await PendingMhpGoogleCalendarCode.consumeAndLinkIfPresent(
      sl<LinkMhpGoogleCalendar>(),
    );
    if (!mounted || !ok) return;
    widget.onSlotsUpdated?.call();
    Get.snackbar(
      'Google Calendar',
      'You\'re set—Meet links are created automatically for paid video sessions.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _connectGoogleCalendar(BuildContext context) async {
    if (AppConfig.googleWebClientId.isEmpty) {
      Get.snackbar(
        'Configuration',
        'Set GOOGLE_OAUTH_CLIENT_ID in .env (same as fly-be).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    setState(() => _calendarLinkBusy = true);
    final GoogleSignIn googleSignIn = createFlyGoogleSignIn();
    try {
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (!mounted) return;
      if (account == null) {
        setState(() => _calendarLinkBusy = false);
        return;
      }
      final code = account.serverAuthCode?.trim();
      if (code == null || code.isEmpty) {
        setState(() => _calendarLinkBusy = false);
        Get.snackbar(
          'Google',
          'No server auth code — try again or set GOOGLE_OAUTH_CLIENT_ID in .env.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      await ApiClient.refreshToken();
      await sl<LinkMhpGoogleCalendar>()(code);
      if (!mounted) return;
      setState(() => _calendarLinkBusy = false);
      widget.onSlotsUpdated?.call();
      Get.snackbar(
        'Google Calendar',
        'You\'re set—Meet links are created automatically for paid video sessions.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() => _calendarLinkBusy = false);
      Get.snackbar(
        'Could not connect',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() => _calendarLinkBusy = false);
      Get.snackbar(
        'Network',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _calendarLinkBusy = false);
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  bool get _needsGoogleReauth =>
      (widget.googleCalendarStatus ?? '').trim() ==
      _kGoogleCalendarReauthRequired;

  bool get _googleLinkedOk =>
      widget.googleCalendarConnected && !_needsGoogleReauth;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadBookedSessions(reset: true),
      child: SingleChildScrollView(
        key: ValueKey(
          '${widget.appointments.length}_${widget.googleCalendarConnected}_${widget.googleCalendarStatus ?? ""}',
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Video sessions'),
            const SizedBox(height: 6),
            if (_needsGoogleReauth) ...[
              _googleCalendarReauthCard(context),
            ] else if (_googleLinkedOk) ...[
              _googleCalendarConnectedCard(context),
            ] else ...[
              Text(
                'Connect Google Calendar so paid video bookings get a Meet link.',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _calendarLinkBusy
                    ? null
                    : () => _connectGoogleCalendar(context),
                icon: _calendarLinkBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.video_camera_front_outlined,
                        size: 20,
                        color: _purple,
                      ),
                label: Text(
                  _calendarLinkBusy ? 'Connecting…' : 'Connect Google Calendar',
                  style: const TextStyle(fontFamily: 'Lexend', color: _purple),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _purple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            _sectionTitle('Your availability'),
            const SizedBox(height: 8),
            if (widget.availableSlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No slots set. Tap below to add your availability.',
                  style: TextStyle(fontFamily: 'Lexend', color: Colors.grey),
                ),
              )
            else
              ...widget.availableSlots.map((s) => _slotTile(s)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openEditSlots(context),
              icon: const Icon(Icons.edit_calendar, size: 20, color: _purple),
              label: const Text(
                'Edit availability',
                style: TextStyle(fontFamily: 'Lexend', color: _purple),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Your bookings'),
            const SizedBox(height: 8),
            _buildBookedSessionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _googleCalendarConnectedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Google Calendar connected',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re set—Meet links are created automatically for paid video sessions.',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _calendarLinkBusy
                  ? null
                  : () => _connectGoogleCalendar(context),
              child: Text(
                'Use a different Google account',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: _purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _googleCalendarReauthCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link_off, color: Colors.orange.shade900, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calendar disconnected—tap to fix',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.orange.shade900,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your Google session may have expired or been revoked. Reconnect to restore Meet links for video bookings.',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _calendarLinkBusy
                ? null
                : () => _connectGoogleCalendar(context),
            icon: _calendarLinkBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange.shade900,
                    ),
                  )
                : Icon(Icons.refresh, size: 20, color: Colors.orange.shade900),
            label: Text(
              _calendarLinkBusy ? 'Connecting…' : 'Reconnect Google Calendar',
              style: TextStyle(
                fontFamily: 'Lexend',
                color: Colors.orange.shade900,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange.shade700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: _purple,
      ),
    );
  }

  Widget _slotTile(Map<String, dynamic> s) {
    final day = s['day']?.toString() ?? '';
    final start = s['start_time']?.toString() ?? '';
    final end = s['end_time']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: _purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$day $start – $end',
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSlots(BuildContext context) {
    final slots = List<Map<String, dynamic>>.from(widget.availableSlots);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditSlotsSheet(
        initialSlots: slots,
        onSave: (newSlots) async {
          Navigator.pop(ctx);
          try {
            await sl<UpdateConnect>().call({'available_slots': newSlots});
            widget.onSlotsUpdated?.call();
            Get.snackbar(
              'Saved',
              'Availability updated',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}

class _EditSlotsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialSlots;
  final void Function(List<Map<String, dynamic>>) onSave;

  const _EditSlotsSheet({required this.initialSlots, required this.onSave});

  @override
  State<_EditSlotsSheet> createState() => _EditSlotsSheetState();
}

class _EditSlotsSheetState extends State<_EditSlotsSheet> {
  late List<Map<String, dynamic>> _slots;
  String _selectedDay = 'Mon';
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _slots = List.from(widget.initialSlots);
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _addSlot() {
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    if (start.isEmpty || end.isEmpty) return;
    setState(() {
      _slots.add({'day': _selectedDay, 'start_time': start, 'end_time': end});
      _startController.clear();
      _endController.clear();
    });
  }

  void _removeAt(int i) {
    setState(() => _slots.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit availability',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                    ),
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedDay = v ?? _days.first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: const InputDecoration(
                      labelText: 'Start (e.g. 09:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: const InputDecoration(
                      labelText: 'End (e.g. 17:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add, color: _purple, size: 20),
                label: const Text(
                  'Add slot',
                  style: TextStyle(color: _purple, fontFamily: 'Lexend'),
                ),
              ),
            ),
            if (_slots.isNotEmpty) ...[
              const Divider(),
              ...List.generate(_slots.length, (i) {
                final s = _slots[i];
                return ListTile(
                  title: Text(
                    '${s['day']} ${s['start_time']} – ${s['end_time']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeAt(i),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onSave(_slots),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Lexend')),
            ),
          ],
        ),
      ),
    );
  }
}
