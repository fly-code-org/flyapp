import 'package:flutter/material.dart';
import 'package:fly/core/config/config.dart';
import 'package:fly/core/config/fly_google_sign_in.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/error/exceptions.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/core/storage/pending_mhp_google_calendar_code.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_booking_card.dart';
import 'package:fly/features/profile_creation/domain/usecases/link_mhp_google_calendar.dart';
import 'package:fly/features/profile_creation/domain/usecases/update_connect.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _purple = Color(0xFF855DFC);

/// Connect tab: Your availability + bookings (sessions). Light purple UI.
class ConnectTabContent extends StatefulWidget {
  final List<Map<String, dynamic>> availableSlots;
  /// Passed from profile; will map to [MhpBookingCard] when integrated.
  final List<Map<String, dynamic>> appointments;
  final VoidCallback? onSlotsUpdated;

  const ConnectTabContent({
    super.key,
    required this.availableSlots,
    required this.appointments,
    this.onSlotsUpdated,
  });

  @override
  State<ConnectTabContent> createState() => _ConnectTabContentState();
}

class _ConnectTabContentState extends State<ConnectTabContent> {
  bool _calendarLinkBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryDeferredCalendarLink());
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
      'Connected — paid video sessions can create Meet links.',
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
        'Connected successfully.',
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: ValueKey(widget.appointments.length),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Video sessions'),
          const SizedBox(height: 6),
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
            onPressed:
                _calendarLinkBusy ? null : () => _connectGoogleCalendar(context),
            icon: _calendarLinkBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.video_camera_front_outlined, size: 20, color: _purple),
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
            label: const Text('Edit availability', style: TextStyle(fontFamily: 'Lexend', color: _purple)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _purple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Your bookings'),
          const SizedBox(height: 8),
          // Demo cards — replace with API-driven list when integrating.
          MhpBookingCard(
            fullName: 'Morgan Ellis',
            username: '@morganellis',
            clientUserId: 'demo-mhp-booking-client-1',
            status: MhpBookingCardStatus.confirmed,
            startTimeLabel: '10:00 AM',
            dateLabel: 'Mar 28, 2025',
          ),
          MhpBookingCard(
            fullName: 'Sam Rivera',
            username: '@samrivera',
            clientUserId: 'demo-mhp-booking-client-2',
            status: MhpBookingCardStatus.pending,
            startTimeLabel: '2:30 PM',
            dateLabel: 'Apr 2, 2025',
          ),
          MhpBookingCard(
            fullName: 'Alex Chen',
            username: '@alexchen',
            clientUserId: 'demo-mhp-booking-client-3',
            status: MhpBookingCardStatus.confirmed,
            startTimeLabel: '9:00 AM',
            dateLabel: 'Apr 5, 2025',
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _EditSlotsSheet(
        initialSlots: slots,
        onSave: (newSlots) async {
          Navigator.pop(ctx);
          try {
            await sl<UpdateConnect>().call({
              'available_slots': newSlots,
            });
            widget.onSlotsUpdated?.call();
            Get.snackbar('Saved', 'Availability updated', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
          } catch (e) {
            Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Edit availability', style: TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
                    items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _selectedDay = v ?? _days.first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _startController, decoration: const InputDecoration(labelText: 'Start (e.g. 09:00)', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _endController, decoration: const InputDecoration(labelText: 'End (e.g. 17:00)', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add, color: _purple, size: 20),
                label: const Text('Add slot', style: TextStyle(color: _purple, fontFamily: 'Lexend')),
              ),
            ),
            if (_slots.isNotEmpty) ...[
              const Divider(),
              ...List.generate(_slots.length, (i) {
                final s = _slots[i];
                return ListTile(
                  title: Text('${s['day']} ${s['start_time']} – ${s['end_time']}', style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeAt(i)),
                );
              }),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onSave(_slots),
              style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save', style: TextStyle(fontFamily: 'Lexend')),
            ),
          ],
        ),
      ),
    );
  }
}
