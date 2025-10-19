import 'package:flutter/material.dart';

class CustomTabWithMedia extends StatefulWidget {
  final Function(int)? onTabChanged;
  const CustomTabWithMedia({super.key, this.onTabChanged});

  @override
  State<CustomTabWithMedia> createState() => _CustomTabWithMediaState();
}

class _CustomTabWithMediaState extends State<CustomTabWithMedia>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {"label": "Activities", "icon": Icons.local_activity_outlined},
    {"label": "About", "icon": Icons.info_outline},
    {"label": "Connect", "icon": Icons.calendar_month_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      widget.onTabChanged?.call(_tabController.index);
      setState(() {}); // update active tab highlight
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getColor(int index) {
    return _tabController.index == index
        ? const Color(0xFF855DFC)
        : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Activities (left aligned)
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF855DFC),
                    labelColor: const Color(0xFF855DFC),
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.transparent,
                    indicatorWeight: 3,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[0]["icon"], color: _getColor(0)),
                          const SizedBox(width: 6),
                          Text(
                            _tabs[0]["label"],
                            style: TextStyle(
                              color: _getColor(0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // My Journal + Bookmarks (right aligned)
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: const Color(0xFF855DFC),
                    labelColor: const Color(0xFF855DFC),
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.transparent,
                    indicatorWeight: 3,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[1]["icon"], color: _getColor(1)),
                          const SizedBox(width: 6),
                          Text(
                            _tabs[1]["label"],
                            style: TextStyle(
                              color: _getColor(1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[2]["icon"], color: _getColor(2)),
                          const SizedBox(width: 6),
                          Text(
                            _tabs[2]["label"],
                            style: TextStyle(
                              color: _getColor(2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Active Tab Indicator line (for visual clarity)
          Container(height: 2, color: const Color(0xFF855DFC).withOpacity(0.2)),
        ],
      ),
    );
  }
}
