import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;

  const DashboardShell({required this.child, super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int currentIndex = 0;

  final List<List<dynamic>> navItems = [
    ["Dashboard", Icons.dashboard_outlined, "/dashboard"],
    ["Chat", Icons.chat_bubble_outline, "/dashboard/chat"],
    ["Kiln Optimizations", Icons.settings_outlined, "/dashboard/optimizations"],
  ];

  void changeTab(int index) {
    if (index == currentIndex) return;
    setState(() {
      currentIndex = index;
      context.go(navItems[index][2] as String);
    });
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // Logger().d("Current location: $location");
    for (int i = 0; i < navItems.length; i++) {
      if (location == navItems[i][2]) {
        return i;
      }
    }
    return currentIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      currentIndex = _getCurrentIndex(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail(
          //   selectedIndex: currentIndex,
          //   onDestinationSelected: changeTab,
          //   labelType: NavigationRailLabelType.all,
          //   destinations: navItems
          //       .map((item) => NavigationRailDestination(icon: Icon(item[1]), label: Text(item[0])))
          //       .toList(),
          // ),
          Container(
            width: 350,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = index == currentIndex;
                return ListTile(
                  leading: Icon(item[1], color: isSelected ? Theme.of(context).colorScheme.primary : null),
                  title: Text(item[0], style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : null)),
                  selected: isSelected,
                  onTap: () => changeTab(index),
                );
              },
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
