import 'package:flutter/material.dart';

class VerticalProgressBar extends StatelessWidget {
  final int selectedIndex; // 0 = bottom, totalOptions-1 = top
  final int totalOptions;
  final ValueChanged<int> onOptionSelected;

  const VerticalProgressBar({
    super.key,
    required this.selectedIndex,
    required this.totalOptions,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barHeight = constraints.maxHeight;
        final stepHeight = barHeight / (totalOptions - 1);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Grey background bar
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Purple gradient fill from bottom to selected
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: stepHeight * selectedIndex,
                width: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Circular button at selected step
            Positioned(
              bottom: stepHeight * selectedIndex - 16,
              child: GestureDetector(
                onTap: () {
                  onOptionSelected(selectedIndex);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class VerticalOptionsSelector extends StatefulWidget {
  final List<String> leftLabels;
  final List<String> rightLabels;

  const VerticalOptionsSelector({
    super.key,
    required this.leftLabels,
    required this.rightLabels,
  });

  @override
  State<VerticalOptionsSelector> createState() =>
      _VerticalOptionsSelectorState();
}

class _VerticalOptionsSelectorState extends State<VerticalOptionsSelector> {
  int selectedIndex = 0; // 0 = bottom, length-1 = top

  void _handleOptionTap(int visualIndex) {
    setState(() {
      selectedIndex = (widget.leftLabels.length - 1) - visualIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.leftLabels.length, (i) {
              return GestureDetector(
                onTap: () => _handleOptionTap(i),
                child: SizedBox(
                  height: 320 / widget.leftLabels.length,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.leftLabels[i],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Progress bar
          SizedBox(
            height: 320,
            child: VerticalProgressBar(
              selectedIndex: selectedIndex,
              totalOptions: widget.leftLabels.length,
              onOptionSelected: (index) {
                setState(() => selectedIndex = index);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Right labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.rightLabels.length, (i) {
              return GestureDetector(
                onTap: () => _handleOptionTap(i),
                child: SizedBox(
                  height: 320 / widget.rightLabels.length,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.rightLabels[i],
                        style: const TextStyle(fontSize: 35),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leftLabels = [
      "1:1 Sessions",
      "Interactive Workshops",
      "Group Discussions",
      "Content Sharing",
      "Self-Help Resources",
    ];

    final rightLabels = ["🤩", "😀", "😊", "😐", "😟"];

    return Scaffold(
      body: Center(
        child: VerticalOptionsSelector(
          leftLabels: leftLabels,
          rightLabels: rightLabels,
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: TestScreen()));
}
