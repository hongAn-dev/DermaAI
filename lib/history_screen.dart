import 'package:flutter/material.dart';
import 'package:myapp/responsive_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      selectedIndex: 3, // Updated index
      child: Center(
        child: Text('History Screen'),
      ),
    );
  }
}
