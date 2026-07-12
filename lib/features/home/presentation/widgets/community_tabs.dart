import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialWellnessTabs extends StatefulWidget {
  final Function(int)? onTabChanged;

  const SocialWellnessTabs({super.key, this.onTabChanged});

  @override
  _SocialWellnessTabsState createState() => _SocialWellnessTabsState();
}

class _SocialWellnessTabsState extends State<SocialWellnessTabs> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTab(
            svgPath: 'assets/icon/social.svg',
            label: 'Social',
            index: 0,
          ),
        ),
        Expanded(
          child: _buildTab(
            svgPath: 'assets/icon/wellness.svg',
            label: 'Wellness',
            index: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required String svgPath,
    required String label,
    required int index,
  }) {
    final bool isActive = activeIndex == index;
    final color = isActive ? Colors.black : Colors.grey;
    return GestureDetector(
      onTap: () {
        setState(() => activeIndex = index);
        if (widget.onTabChanged != null) widget.onTabChanged!(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
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
