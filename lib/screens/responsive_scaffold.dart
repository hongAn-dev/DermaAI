import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: // Home
        context.go('/home');
        break;
      case 1: // Scan
        context.go('/scan');
        break;
      case 2: // Consult
        context.go('/consult');
        break;
      case 3: // History
        context.go('/history');
        break;
      case 4: // Profile
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the destinations once
    final destinations = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: 'Scan'),
      const BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services), label: 'Consult'),
      const BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile View
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              items: destinations,
              type: BottomNavigationBarType.fixed, // Ensures all items are visible
              selectedItemColor: const Color(0xFF18A0FB), // Active color
              unselectedItemColor: Colors.grey[600], // Inactive color
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showUnselectedLabels: true,
            ),
          );
        } 
        // Web/Desktop View
        else {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations.map((item) => NavigationRailDestination(
                    icon: item.icon,
                    selectedIcon: item.activeIcon,
                    label: Text(item.label!)
                  )).toList(),
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFE3F6FF), // Light blue indicator
                  selectedIconTheme: const IconThemeData(color: Color(0xFF18A0FB)),
                  unselectedIconTheme: IconThemeData(color: Colors.grey[600]!),
                  selectedLabelTextStyle: const TextStyle(color: Color(0xFF18A0FB), fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}
