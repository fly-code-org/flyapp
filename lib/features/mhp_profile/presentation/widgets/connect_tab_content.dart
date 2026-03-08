import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/profile_creation/domain/usecases/update_connect.dart';
import 'package:get/get.dart';

const _purple = Color(0xFF855DFC);

/// Connect tab: Your availability + Upcoming sessions. Light purple UI.
class ConnectTabContent extends StatelessWidget {
  final List<Map<String, dynamic>> availableSlots;
  final List<Map<String, dynamic>> appointments;
  final VoidCallback? onSlotsUpdated;

  const ConnectTabContent({
    super.key,
    required this.availableSlots,
    required this.appointments,
    this.onSlotsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Your availability'),
          const SizedBox(height: 8),
          if (availableSlots.isEmpty)
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
            ...availableSlots.map((s) => _slotTile(s)),
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
          _sectionTitle('Upcoming sessions'),
          const SizedBox(height: 8),
          if (appointments.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No upcoming sessions.',
                style: TextStyle(fontFamily: 'Lexend', color: Colors.grey),
              ),
            )
          else
            ...appointments.map((a) => _appointmentTile(a)),
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

  Widget _appointmentTile(Map<String, dynamic> a) {
    final date = a['date']?.toString() ?? '';
    final time = a['time']?.toString() ?? '';
    final status = a['status']?.toString() ?? '';
    final preference = a['preference']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: _purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$date · $time', style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w500)),
                if (preference.isNotEmpty) Text(preference, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                if (status.isNotEmpty) Text(status, style: TextStyle(fontSize: 12, color: _purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSlots(BuildContext context) {
    final slots = List<Map<String, dynamic>>.from(availableSlots);
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
            onSlotsUpdated?.call();
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
