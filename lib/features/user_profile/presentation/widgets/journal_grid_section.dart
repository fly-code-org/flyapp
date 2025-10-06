import 'dart:math';
import 'package:flutter/material.dart';

class JournalGridSection extends StatelessWidget {
  const JournalGridSection({super.key});

  List<Map<String, dynamic>> get mockJournals => List.generate(6, (index) {
    final colors = [
      const Color(0xFFFFD6E0),
      const Color(0xFFD0E8F2),
      const Color(0xFFE8EAF6),
      const Color(0xFFFFF3CD),
      const Color(0xFFD1F7C4),
      const Color(0xFFFFE4C4),
    ];
    return {
      "title": "Journal ${index + 1}",
      "date": "Oct ${10 + index}, 2025",
      "color": colors[Random().nextInt(colors.length)],
    };
  });

  @override
  Widget build(BuildContext context) {
    final journals = mockJournals;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: journals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = journals[index];
        return Container(
          decoration: BoxDecoration(
            color: item["color"],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item["title"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                item["date"],
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Lexend',
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
