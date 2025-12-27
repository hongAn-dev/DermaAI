import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/responsive.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management',
            style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Text('No users',
                    style: GoogleFonts.manrope(
                        fontSize: Responsive.fontSize(context, 16))));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final d = docs[idx];
              final data = d.data() as Map<String, dynamic>;
              final role = data['role'] as String? ?? 'user';
              return ListTile(
                title: Text(data['displayName'] ?? data['email'] ?? d.id,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? '',
                    style: GoogleFonts.manrope(color: Colors.grey[600])),
                trailing: DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(d.id)
                        .update({'role': v});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
