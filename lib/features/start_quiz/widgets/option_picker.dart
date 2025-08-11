import 'package:flutter/material.dart';

class GradientOptionSelector extends StatefulWidget {
  final List<OptionItem> options;
  final Function(int) onSelected;

  const GradientOptionSelector({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<GradientOptionSelector> createState() => _GradientOptionSelectorState();
}

class _GradientOptionSelectorState extends State<GradientOptionSelector> {
  int selectedIndex = -1;

  final Gradient purpleGradient = const LinearGradient(
    colors: [
      Color(0xFFC36AFD), // Purple start
      Color(0xFF7A5AF8), // Purple end
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.options.length, (index) {
        final isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onSelected(index);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? purpleGradient : null,
              border: 
              isSelected
                  ? null
                  : Border.all(color: const Color.fromARGB(226, 235, 232, 232), width: 1.5),
              borderRadius: BorderRadius.circular(40),
              color: isSelected ? null : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.options[index].icon,
                      color: isSelected
                          ? Colors.white
                          : Colors.purple.withOpacity(0.4),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.options[index].label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected
                            ? Colors.white
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                // Radio circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class OptionItem {
  final IconData icon;
  final String label;

  OptionItem({required this.icon, required this.label});
}
