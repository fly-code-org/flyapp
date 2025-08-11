import 'package:flutter/material.dart';

class OptionsGrid extends StatefulWidget {
  final void Function(int) onOptionSelected;

  const OptionsGrid({Key? key, required this.onOptionSelected}) : super(key: key);

  @override
  State<OptionsGrid> createState() => _OptionsGridState();
}

class _OptionsGridState extends State<OptionsGrid> {
  final List<String> emojis = ['🏫', '🎓', '💼', '🤐'];
  final List<String> labels = ['School', 'College', '\t\t\tWorking\nProfessional', 'Prefer not to say'];

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
        physics: NeverScrollableScrollPhysics(),
        itemCount: emojis.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  color: isSelected ? const Color.fromARGB(255, 152, 71, 195) : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emojis[index],
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: TextStyle(
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
