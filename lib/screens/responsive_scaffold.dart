import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  Future<void> _onItemTapped(int index, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    String role = 'user';
    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!context.mounted) return;
        if (doc.exists) role = doc.data()?['role'] ?? 'user';
      } catch (_) {}
    }

    switch (index) {
      case 0: // Home
        context.go('/home');
        break;
      case 1: // Scan
        context.go('/scan');
        break;
      case 2: // Consult or Chats depending on role
        if (role == 'doctor') {
          context.go('/chats');
        } else {
          context.go('/consult');
        }
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Widget buildNav(
            List<BottomNavigationBarItem> destinations, BuildContext ctx) =>
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Scaffold(
                body: child,
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  items: destinations,
                  type: BottomNavigationBarType
                      .fixed, // Ensures all items are visible
                  selectedItemColor: const Color(0xFF18A0FB), // Active color
                  unselectedItemColor: Colors.grey[600], // Inactive color
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  showUnselectedLabels: true,
                ),
              );
            } else {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) =>
                          _onItemTapped(index, context),
                      labelType: NavigationRailLabelType.selected,
                      destinations: destinations
                          .map((item) => NavigationRailDestination(
                              icon: item.icon,
                              selectedIcon: item.activeIcon,
                              label: Text(item.label!)))
                          .toList(),
                      backgroundColor: Colors.white,
                      indicatorColor: const Color(0xFFE3F6FF),
                      selectedIconTheme:
                          const IconThemeData(color: Color(0xFF18A0FB)),
                      unselectedIconTheme:
                          IconThemeData(color: Colors.grey[600]!),
                      selectedLabelTextStyle: const TextStyle(
                          color: Color(0xFF18A0FB),
                          fontWeight: FontWeight.bold),
                      unselectedLabelTextStyle:
                          TextStyle(color: Colors.grey[600]),
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: child),
                  ],
                ),
              );
            }
          },
        );

    // If user not signed-in yet, render default destinations
    if (uid == null) {
      final destinations = [
        const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Quét'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Tư vấn'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ'),
      ];
      return buildNav(destinations, context);
    }

    // Listen to Firestore user doc for role changes
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final role =
            snapshot.hasData ? (snapshot.data!.get('role') ?? 'user') : 'user';
        final destinations = [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Quét'),
          role == 'doctor'
              ? const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  activeIcon: Icon(Icons.chat_bubble),
                  label: 'Trò chuyện')
              : const BottomNavigationBarItem(
                  icon: Icon(Icons.medical_services_outlined),
                  activeIcon: Icon(Icons.medical_services),
                  label: 'Tư vấn'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Lịch sử'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Hồ sơ'),
        ];

        return buildNav(destinations, context);
      },
    );
  }
}
