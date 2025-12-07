import 'package:flutter/material.dart';

class SelectableCards extends StatefulWidget {
  final List<Map<String, dynamic>>? cards;
  final void Function(int)? onOptionSelected;
  
  const SelectableCards({Key? key, this.cards, this.onOptionSelected}) : super(key: key);

  @override
  State<SelectableCards> createState() => _SelectableCardsState();
}

class _SelectableCardsState extends State<SelectableCards> {
  int? selectedIndex;

  void _onSelect(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (widget.onOptionSelected != null) {
      widget.onOptionSelected!(index);
    }
  }

  Widget _buildCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onSelect(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF855DFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF855DFC) : Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardsData = widget.cards ?? [
      {
        'icon': Icons.check,
        'title': "Yes, one or multiple",
        'subtitle': "Found helpful tools, Explored mindfulness, Accessed therapy resources",
      },
      {
        'icon': Icons.close,
        'title': "I haven't used any apps",
        'subtitle': "Prefer traditional methods, Not familiar with apps.",
      },
    ];

    return Column(
      children: List.generate(cardsData.length, (index) {
        return _buildCard(
          index: index,
          icon: cardsData[index]['icon'] as IconData,
          title: cardsData[index]['title'] as String,
          subtitle: cardsData[index]['subtitle'] as String,
        );
      }),
    );
  }
}
