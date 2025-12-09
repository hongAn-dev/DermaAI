import 'package:flutter/material.dart';
import 'package:myapp/responsive_scaffold.dart';

class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      selectedIndex: 2, // New index for Consult
      child: Center(
        child: Text('Consult Screen'),
      ),
    );
  }
}
