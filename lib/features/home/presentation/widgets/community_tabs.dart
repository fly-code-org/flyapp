import 'package:flutter/material.dart';

class SocialSupportTabs extends StatefulWidget {
  const SocialSupportTabs({super.key});

  @override
  _SocialSupportTabsState createState() => _SocialSupportTabsState();
}

class _SocialSupportTabsState extends State<SocialSupportTabs> {
  int activeIndex = 0; // 0 -> Social, 1 -> Support

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Social tab
        Expanded(
          child: _buildTab(icon: Icons.people, label: "Social", index: 0),
        ),

        // Support tab
        Expanded(
          child: _buildTab(
            icon: Icons.support_agent,
            label: "Support",
            index: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = activeIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + Text centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? Colors.black : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Underline stretches full half width
          Container(
            height: 3,
            width: double.infinity, // Full width of Expanded
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF855DFC) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
