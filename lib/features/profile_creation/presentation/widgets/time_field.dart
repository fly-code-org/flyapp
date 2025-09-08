import 'package:flutter/material.dart';

class TimeAvailabilityField extends StatefulWidget {
  final Function(TimeOfDay from, TimeOfDay to) onTimeSelected;

  const TimeAvailabilityField({super.key, required this.onTimeSelected});

  @override
  State<TimeAvailabilityField> createState() => _TimeAvailabilityFieldState();
}

class _TimeAvailabilityFieldState extends State<TimeAvailabilityField> {
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  Future<void> _pickTime(bool isFrom) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
      if (_fromTime != null && _toTime != null) {
        widget.onTimeSelected(_fromTime!, _toTime!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "From time to To time",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // From Time Button
              GestureDetector(
                onTap: () => _pickTime(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                  child: Text(
                    _fromTime != null ? _fromTime!.format(context) : "From",
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // To Time Button
              GestureDetector(
                onTap: () => _pickTime(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                  child: Text(
                    _toTime != null ? _toTime!.format(context) : "To",
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
