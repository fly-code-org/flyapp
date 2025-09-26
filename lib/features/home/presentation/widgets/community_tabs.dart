import 'package:flutter/material.dart';

class SocialSupportTabs extends StatefulWidget {
  final Function(int)? onTabChanged;

  const SocialSupportTabs({super.key, this.onTabChanged});

  @override
  _SocialSupportTabsState createState() => _SocialSupportTabsState();
}

class _SocialSupportTabsState extends State<SocialSupportTabs> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTab(icon: Icons.people, label: "Social", index: 0),
        ),
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
        if (widget.onTabChanged != null) widget.onTabChanged!(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            height: 3,
            width: double.infinity,
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
