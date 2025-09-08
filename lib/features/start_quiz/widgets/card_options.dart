import 'package:flutter/material.dart';

class OptionsGrid extends StatefulWidget {
  final List<String> emojis; // ✅ Dynamic emojis
  final List<String> labels; // ✅ Dynamic labels
  final void Function(int) onOptionSelected;

  const OptionsGrid({
    Key? key,
    required this.emojis,
    required this.labels,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  State<OptionsGrid> createState() => _OptionsGridState();
}

class _OptionsGridState extends State<OptionsGrid> {
  int? selectedIndex;

  void _onTap(int index) {
    setState(() {
      selectedIndex = index;
      widget.onOptionSelected(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.emojis.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return InkWell(
            onTap: () => _onTap(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(255, 152, 71, 195)
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.emojis[index],
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.labels[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
