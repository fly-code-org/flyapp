import 'package:flutter/material.dart';

class SelectablePillList extends StatefulWidget {
  final List<String> options; // e.g. ["Online", "In-Person", "Hybrid"]
  final ValueChanged<List<String>>
  onSelectionChanged; // callback with selected list

  const SelectablePillList({
    super.key,
    required this.options,
    required this.onSelectionChanged,
  });

  @override
  State<SelectablePillList> createState() => _SelectablePillListState();
}

class _SelectablePillListState extends State<SelectablePillList> {
  final List<String> _selected = [];

  void _toggleSelection(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
    widget.onSelectionChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((option) {
        final bool isSelected = _selected.contains(option);
        return GestureDetector(
          onTap: () => _toggleSelection(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF9C27B0), // Purple
                        Color(0xFFE91E63), // Pink
                      ],
                    )
                  : null,
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey,
                width: 1.5,
              ),
              color: isSelected ? null : Colors.transparent,
            ),
            child: Text(
              option,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
