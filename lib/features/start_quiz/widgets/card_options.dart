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
          // Slightly taller than square so long labels (e.g. 3 lines) fit.
          childAspectRatio: 0.82,
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
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.emojis[index],
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  // Flexible + ellipsis keeps long labels within the card bounds.
                  Flexible(
                    child: Text(
                      widget.labels[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
