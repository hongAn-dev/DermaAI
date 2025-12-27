import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart'; // Đừng quên import package này
import 'package:myapp/utils/responsive.dart';
import 'chat_screen.dart';
import 'consult_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();
    final ref = FirebaseDatabase.instance
        .ref('user_chats/${user!.uid}')
        .orderByChild('timestamp');

    return Scaffold(
      appBar: AppBar(
        // --- THÊM PHẦN NÀY ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Quay về trang chủ (hoặc dùng context.pop() nếu chỉ muốn quay lại trang trước)
            context.go('/home');
          },
        ),
        // ---------------------
        title: Text('Conversations',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 20),
                color: Colors.black)), // Đảm bảo màu chữ là đen cho đồng bộ
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.delete_forever : Icons.edit,
                color: Colors.black),
            onPressed: () => setState(() => _editing = !_editing),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Căn giữa tiêu đề cho đẹp khi có nút back
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return Center(
                child: Text('No conversations',
                    style: GoogleFonts.manrope(
                        fontSize: Responsive.fontSize(context, 16),
                        color: Colors.grey[600])));
          }
          final map = snap.data!.snapshot.value as Map<Object?, Object?>;
          final list = map.entries.map((e) {
            final v = e.value as Map<Object?, Object?>;
            return {
              'chatId': v['chatId'] ?? e.key,
              'otherId': v['otherId'] ?? '',
              'lastMessage': v['lastMessage'] ?? '',
              'timestamp': v['timestamp'] ?? 0,
            };
          }).toList()
            ..sort((a, b) =>
                (b['timestamp'] as int).compareTo(a['timestamp'] as int));

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final item = list[idx];
              final chatId = item['chatId'] as String;
              final otherId = item['otherId'] as String;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherId)
                    .get(),
                builder: (context, userSnap) {
                  String displayName = otherId;
                  String? photoUrl;
                  if (userSnap.hasData && userSnap.data!.exists) {
                    final d = userSnap.data!.data() as Map<String, dynamic>?;
                    if (d != null) {
                      displayName = d['displayName'] as String? ?? displayName;
                      photoUrl = d['photoUrl'] as String?;
                    }
                  }
                  return ListTile(
                    leading: photoUrl != null && photoUrl.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(photoUrl))
                        : CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Text(
                                displayName.isNotEmpty ? displayName[0] : '?')),
                    title: Text(displayName,
                        style:
                            GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['lastMessage'] as String,
                        style: GoogleFonts.manrope(color: Colors.grey[600])),
                    trailing: _editing
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // delete chat data and indexes
                              await FirebaseDatabase.instance
                                  .ref('chats/$chatId')
                                  .remove();
                              await FirebaseDatabase.instance
                                  .ref('user_chats/${user!.uid}/$chatId')
                                  .remove();
                              // also remove from other participant index if known
                              if (otherId.isNotEmpty) {
                                await FirebaseDatabase.instance
                                    .ref('user_chats/$otherId/$chatId')
                                    .remove();
                              }
                              setState(() {});
                            },
                          )
                        : const Text('', style: TextStyle(color: Colors.grey)),
                    onTap: _editing
                        ? null
                        : () async {
                            // open chat screen
                            final doctorDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(otherId)
                                .get();
                            final d = doctorDoc.data();
                            final doctor = Doctor(
                                uid: otherId,
                                name: d?['displayName'] as String? ?? otherId,
                                specialization:
                                    d?['specialization'] as String? ?? '',
                                rating: 0.0,
                                reviewCount: 0,
                                nextAvailable: '',
                                imagePath: d?['photoUrl'] as String? ?? '');

                            if (!context.mounted) return;

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ChatScreen(doctor: doctor)));
                          },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
