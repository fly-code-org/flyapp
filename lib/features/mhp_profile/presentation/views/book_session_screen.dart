import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _purple = Color(0xFF855DFC);

/// When a user taps Connect on an MHP profile: pick date, preference, duration, slot, then "Let's connect".
class BookSessionScreen extends StatefulWidget {
  final String? mhpId;

  const BookSessionScreen({super.key, this.mhpId});

  @override
  State<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends State<BookSessionScreen> {
  DateTime _selectedDate = DateTime.now();
  String _preference = 'Video';
  String _duration = '30mins';
  String? _selectedSlot;

  static const _preferences = ['Video', 'Call', 'In-person'];
  static const _durations = ['30mins', '45mins', '60mins', '90mins'];
  static const _slots = ['4pm', '6pm', '8pm'];

  @override
  Widget build(BuildContext context) {
    final monthYear = '${_selectedDate.day} ${_monthName(_selectedDate.month)}, ${_selectedDate.year}';
    final weekDates = _weekDates(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Connect', style: TextStyle(fontFamily: 'Lexend', color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(monthYear, style: const TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7))), icon: const Icon(Icons.chevron_left)),
                    IconButton(onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7))), icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) => SizedBox(width: 32, child: Center(child: Text(d, style: TextStyle(fontSize: 12, color: Colors.grey[600]))))).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDates.map((d) {
                final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = d),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? _purple : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(d.day.toString(), style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : Colors.black))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text('Preference', style: TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: _preferences.map((p) {
                final selected = _preference == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _chip(
                    label: p,
                    icon: p == 'Video' ? Icons.videocam : p == 'Call' ? Icons.call : Icons.person,
                    selected: selected,
                    onTap: () => setState(() => _preference = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Dur', style: TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: _durations.map((d) {
                final selected = _duration == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _chip(label: d, selected: selected, onTap: () => setState(() => _duration = d)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Available slots', style: TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: _slots.map((s) {
                final selected = _selectedSlot == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _chip(label: s, selected: selected, onTap: () => setState(() => _selectedSlot = s)),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () {
                  if (_selectedSlot == null) {
                    Get.snackbar('Select a slot', 'Choose an available time', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.snackbar('Let\'s connect', 'Booking will be confirmed soon', snackPosition: SnackPosition.BOTTOM, backgroundColor: _purple, colorText: Colors.white);
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFC36AFD), Color(0xFF7A5AF8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text("Let's connect", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required String label, IconData? icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _purple : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: selected ? Colors.white : Colors.grey), const SizedBox(width: 6)],
            Text(label, style: TextStyle(fontFamily: 'Lexend', fontSize: 14, color: selected ? Colors.white : Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return names[m - 1];
  }

  List<DateTime> _weekDates(DateTime ref) {
    final daysToSunday = ref.weekday == 7 ? 0 : ref.weekday;
    final start = ref.subtract(Duration(days: daysToSunday));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}
