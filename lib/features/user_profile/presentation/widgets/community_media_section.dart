import 'package:flutter/material.dart';

class CustomTabWidget extends StatefulWidget {
  const CustomTabWidget({super.key});

  @override
  State<CustomTabWidget> createState() => _CustomTabWidgetState();
}

class _CustomTabWidgetState extends State<CustomTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // rebuild to update icon colors
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
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
                  Icon(Icons.show_chart_sharp, color: _getColor(1)),
                  const SizedBox(width: 6),
                  Text("Popular", style: TextStyle(color: _getColor(1))),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 150,
          child: TabBarView(
            controller: _tabController,
            children: const [
              Center(child: Text("New Tab Content")),
              Center(child: Text("Popular Tab Content")),
            ],
          ),
        ),
      ],
    );
  }
}
