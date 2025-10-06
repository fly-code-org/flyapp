import 'package:flutter/material.dart';

/// Pill-shaped Media button with gradient
class MediaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MediaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF855DFC), Color(0xFFA68CFC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.perm_media, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Media",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Tab widget with Media button (uses DefaultTabController)
class CustomTabWithMedia extends StatelessWidget {
  final VoidCallback onMediaPressed;

  const CustomTabWithMedia({super.key, required this.onMediaPressed});

  @override
  Widget build(BuildContext context) {
    final TabController tabController = DefaultTabController.of(context)!;

    Color _getColor(int index) {
      return tabController.index == index
          ? const Color(0xFF855DFC)
          : Colors.grey;
    }

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF855DFC),
              labelColor: const Color(0xFF855DFC),
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_outward, color: _getColor(0)),
                      const SizedBox(width: 6),
                      Text("New", style: TextStyle(color: _getColor(0))),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, color: _getColor(1)),
                      const SizedBox(width: 6),
                      Text("Popular", style: TextStyle(color: _getColor(1))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        MediaButton(onPressed: onMediaPressed),
      ],
    );
  }
}
