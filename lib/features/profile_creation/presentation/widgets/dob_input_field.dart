import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DOBInputField extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final String? hintText;

  const DOBInputField({
    super.key,
    required this.onDateSelected,
    this.hintText,
  });

  @override
  State<DOBInputField> createState() => _DOBInputFieldState();
}

class _DOBInputFieldState extends State<DOBInputField> {
  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18), // Default: 18 years old
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 188, 138, 235),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        width: 377,
        height: 57,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate!)
                    : (widget.hintText ?? 'Select Date of Birth'),
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 20.5 / 18,
                  letterSpacing: 0.15,
                  color: selectedDate != null
                      ? Colors.black
                      : Colors.grey.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
