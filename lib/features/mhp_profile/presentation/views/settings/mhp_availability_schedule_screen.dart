import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class _TimeSlot {
  TimeOfDay from;
  TimeOfDay to;
  _TimeSlot({required this.from, required this.to});
}

class MhpAvailabilityScheduleScreen extends StatefulWidget {
  const MhpAvailabilityScheduleScreen({super.key});

  @override
  State<MhpAvailabilityScheduleScreen> createState() =>
      _MhpAvailabilityScheduleScreenState();
}

class _MhpAvailabilityScheduleScreenState
    extends State<MhpAvailabilityScheduleScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final _daysFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  Set<String> _selectedDays = {'Mon', 'Thu', 'Sun'};
  List<_TimeSlot> _slots = [
    _TimeSlot(from: const TimeOfDay(hour: 17, minute: 0), to: const TimeOfDay(hour: 17, minute: 0))
  ];
  bool _applyToAll = true;
  bool _blockAll = false;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getAvailability();
      final rawSlots = data['available_slots'];
      if (rawSlots is List && rawSlots.isNotEmpty) {
        final days = <String>{};
        final timeSlots = <_TimeSlot>[];
        for (final s in rawSlots) {
          if (s is Map) {
            final day = s['day']?.toString() ?? '';
            final shortDay = day.length >= 3 ? day.substring(0, 3) : day;
            days.add(shortDay);
            if (timeSlots.isEmpty) {
              timeSlots.add(_TimeSlot(
                from: _parseTime(s['start_time']?.toString() ?? '09:00'),
                to: _parseTime(s['end_time']?.toString() ?? '17:00'),
              ));
            }
          }
        }
        if (days.isNotEmpty) _selectedDays = days;
        if (timeSlots.isNotEmpty) _slots = timeSlots;
      }
      _blockAll = data['block_all_bookings'] == true;
    } catch (_) {}
    setState(() => _loading = false);
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0);
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isFrom, int slotIndex) async {
    final current = isFrom ? _slots[slotIndex].from : _slots[slotIndex].to;
    await showModalBottomSheet(
      context: context,
      builder: (_) => _TimePicker(
        initial: current,
        onChanged: (t) => setState(() {
          if (isFrom) {
            _slots[slotIndex].from = t;
          } else {
            _slots[slotIndex].to = t;
          }
        }),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select at least one day')));
      return;
    }
    setState(() => _saving = true);
    try {
      final availableSlots = <Map<String, dynamic>>[];
      for (final shortDay in _selectedDays) {
        final idx = _days.indexOf(shortDay);
        final fullDay = idx >= 0 ? _daysFull[idx] : shortDay;
        if (_applyToAll) {
          for (final slot in _slots) {
            availableSlots.add({
              'day': fullDay,
              'start_time': _formatTime(slot.from),
              'end_time': _formatTime(slot.to),
            });
          }
        } else {
          for (final slot in _slots) {
            availableSlots.add({
              'day': fullDay,
              'start_time': _formatTime(slot.from),
              'end_time': _formatTime(slot.to),
            });
          }
        }
      }
      await _ds.updateConnect({
        'available_slots': availableSlots,
        'block_all_bookings': _blockAll,
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Availability updated')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _saving = false);
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
          title: const Text('Availability Schedule',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selected days',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map(_dayChip).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Text('Your selected time availability:',
                              style: TextStyle(fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 12),
                          ..._slots.asMap().entries.map((e) => _slotRow(e.key)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _applyToAll,
                                activeColor: Colors.red,
                                onChanged: (v) =>
                                    setState(() => _applyToAll = v ?? true),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              const Text('Apply same time at selected days',
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _slots.add(_TimeSlot(
                                from: const TimeOfDay(hour: 9, minute: 0),
                                to: const TimeOfDay(hour: 17, minute: 0)))),
                            icon: const Icon(Icons.add, color: Colors.black87, size: 18),
                            label: const Text('Add another slot',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 16),
                          const Text('Unavailability',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE8E8E8)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Block all bookings',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    Text('Pause sessions temporarily',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.black45)),
                                  ],
                                ),
                                Switch(
                                  value: _blockAll,
                                  onChanged: (v) =>
                                      setState(() => _blockAll = v),
                                  activeColor: _purple,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _dayChip(String day) {
    final selected = _selectedDays.contains(day);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedDays.remove(day);
        } else {
          _selectedDays.add(day);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          border: Border.all(
              color: selected ? _purple : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(day,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13)),
      ),
    );
  }

  Widget _slotRow(int idx) {
    final slot = _slots[idx];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: _timePicker('To', slot.from, () => _pickTime(true, idx))),
          const SizedBox(width: 12),
          Expanded(child: _timePicker('From', slot.to, () => _pickTime(false, idx))),
          if (_slots.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() => _slots.removeAt(idx)),
            ),
        ],
      ),
    );
  }

  Widget _timePicker(String label, TimeOfDay time, VoidCallback onTap) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                const SizedBox(height: 2),
                Text(
                  '$hour:${time.minute.toString().padLeft(2, '0')} $period',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatefulWidget {
  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;
  const _TimePicker({required this.initial, required this.onChanged});

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Select Time',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                  2024, 1, 1, widget.initial.hour, widget.initial.minute),
              onDateTimeChanged: (dt) {
                widget.onChanged(TimeOfDay(hour: dt.hour, minute: dt.minute));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
