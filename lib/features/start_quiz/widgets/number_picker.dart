import 'package:flutter/material.dart';

class PickerWithBall extends StatefulWidget {
  final List<String> options; // What user taps on (emojis, numbers, etc.)
  final List<String>? labels; // Optional mapped labels for top text
  final int initialIndex; // Default selection
  final double displayFontSize; // Top text size
  final void Function(String value, int index)? onChanged; // Callback

  const PickerWithBall({
    Key? key,
    required this.options,
    this.labels,
    this.initialIndex = 0,
    this.displayFontSize = 100,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PickerWithBall> createState() => _PickerWithBallState();
}

class _PickerWithBallState extends State<PickerWithBall> {
  late int selectedIndex;

  final RadialGradient purpleRadialGradient = const RadialGradient(
    colors: [
      Color(0xFFC36AFD), // Purple gradient start
      Color(0xFF7A5AF8), // Purple gradient end
    ],
    center: Alignment.center,
    radius: 0.8,
  );

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // If labels provided, show them on top, else fallback to options
    final selectedValue = widget.labels != null
        ? widget.labels![selectedIndex]
        : widget.options[selectedIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Big text showing selected value/label
        Text(
          selectedValue,
          style: TextStyle(
            fontSize: widget.displayFontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = purpleRadialGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 200),
              ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Pill container with dynamic options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.options.length, (index) {
              String option = widget.options[index];
              bool isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(option, index);
                  }
                },
                child: Container(
                  width: 50,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular purple ball behind selected item
                      if (isSelected)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: purpleRadialGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xAA7B2FF7),
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),

                      // Option text (emoji/number/string)
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
