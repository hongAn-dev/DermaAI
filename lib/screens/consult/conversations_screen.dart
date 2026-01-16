import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Query;
import 'package:go_router/go_router.dart'; // Đừng quên import package này
import 'package:myapp/utils/responsive.dart';
import 'chat_screen.dart';
import '../../data/models/doctor_model.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  // Check if dispose is needed for anything else. If not, remove it or keep super.
  // Since we are removing search controller, we don't need to dispose it.
  // But strictly speaking, if we don't hold any listenable/controller, we can remove the override.
  // However, removing the variables is the main goal.
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();
    final ref = FirebaseDatabase.instance
        .ref('user_chats/${user!.uid}')
        .orderByChild('timestamp');

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snap) {
        // --- 1. Process Data & Filter ---
        // Determine raw list
        List<Map<String, dynamic>> rawList = [];
        if (snap.hasData && snap.data!.snapshot.value != null) {
          final map = snap.data!.snapshot.value as Map<Object?, Object?>;
          rawList = map.entries.map((e) {
            final v = e.value as Map<Object?, Object?>;
            return {
              'chatId': v['chatId'] ?? e.key,
              'otherId': v['otherId'] ?? '',
              'lastMessage': v['lastMessage'] ?? '',
              'timestamp': v['timestamp'] ?? 0,
            };
          }).toList();
        }

        // Sort by timestamp
        final filteredList = rawList
          ..sort((a, b) =>
              (b['timestamp'] as int).compareTo(a['timestamp'] as int));

        // Check if we have ANY chats (ignoring filter) to show/hide actions
        final hasChats = rawList.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/home'),
            ),
            title: Text('Cuộc trò chuyện',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 20),
                    color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide =
                    Responsive.deviceType(context) != DeviceType.mobile;

                // Handle Loading/Error/Empty States inside body
                if (snap.hasError) {
                  return Center(child: Text('Lỗi: ${snap.error}'));
                }

                // If list is empty (regardless of filter, if total is 0)
                if (!hasChats) {
                  return _buildEmptyState();
                }

                // If filter result is empty
                if (filteredList.isEmpty) {
                  return Center(
                      child: Text('Không tìm thấy cuộc trò chuyện nào',
                          style: GoogleFonts.manrope(color: Colors.grey)));
                }

                if (isWide) {
                  return Row(
                    children: [
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: _buildChatListView(filteredList),
                      ),
                      Expanded(
                        child: _buildWelcomePanel(),
                      ),
                    ],
                  );
                } else {
                  return _buildChatListView(filteredList);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có cuộc trò chuyện nào',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePanel() {
    return Container(
      color: Colors.white60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_outlined,
              size: 80,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chào mừng đến với DermaAI',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chọn một cuộc trò chuyện để bắt đầu\nhoặc liên hệ với bác sĩ mới.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListView(List<Map<String, dynamic>> filteredList) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(
            vertical: Responsive.scale(context, 16), horizontal: 16),
        itemCount: filteredList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final item = filteredList[idx];
          final chatId = item['chatId'] as String;
          var otherId = item['otherId'] as String;
          final timestamp = item['timestamp'] as int;
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final timeStr =
              "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

          if (otherId.isEmpty) {
            // Fallback: Try to extract otherId from chatId
            if (chatId.contains('_')) {
              final parts = chatId.split('_');
              if (parts.length == 2) {
                if (parts[0] == user!.uid) {
                  otherId = parts[1];
                } else if (parts[1] == user!.uid) {
                  otherId = parts[0];
                }
              }
            }
          }

          if (otherId.isEmpty) {
            return const SizedBox.shrink();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(otherId)
                .get(),
            builder: (context, userSnap) {
              String displayName = 'Người dùng';
              String? photoUrl;
              if (userSnap.hasData && userSnap.data!.exists) {
                final d = userSnap.data!.data() as Map<String, dynamic>?;
                if (d != null) {
                  displayName = d['displayName'] as String? ?? displayName;
                  photoUrl = d['photoUrl'] as String?;
                }
              }

              return Dismissible(
                key: Key(chatId),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Xác nhận"),
                        content: const Text(
                            "Bạn có chắc chắn muốn xóa cuộc trò chuyện này không?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Xóa",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  // 1. Soft Delete: Set "visibleFrom" timestamp (Best Effort)
                  try {
                    await FirebaseDatabase.instance
                        .ref('user_chat_prefs/${user!.uid}/$chatId/visibleFrom')
                        .set(ServerValue.timestamp);
                  } catch (e) {
                    debugPrint(
                        "Lỗi lưu tùy chọn ẩn tin nhắn cũ (không ảnh hưởng việc xóa): $e");
                  }

                  // 2. Remove from MY inbox (user_chats) - This is the main action
                  try {
                    await FirebaseDatabase.instance
                        .ref('user_chats/${user!.uid}/$chatId')
                        .remove();
                  } catch (e) {
                    debugPrint("Lỗi xóa cuộc trò chuyện: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Lỗi xóa cuộc trò chuyện: $e')));
                    }
                    // Since Dismissible already removed the item from UI,
                    // if this fails, the stream will likely rebuild and put it back.
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final doctorDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherId)
                              .get();
                          final d = doctorDoc.data();

                          final partner = Doctor(
                              uid: otherId,
                              name: d?['displayName'] as String? ?? otherId,
                              specialization: 'Patient', // or check role
                              rating: 0.0,
                              reviewCount: 0,
                              nextAvailable: '',
                              imagePath: d?['photoUrl'] as String? ?? '');

                          if (!context.mounted) return;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatScreen(doctor: partner)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blue.shade50,
                                backgroundImage:
                                    (photoUrl != null && photoUrl!.isNotEmpty)
                                        ? (photoUrl!.startsWith('http')
                                            ? NetworkImage(photoUrl!)
                                            : (photoUrl!.startsWith('assets')
                                                ? AssetImage(photoUrl!)
                                                    as ImageProvider
                                                : null))
                                        : null,
                                child: (photoUrl == null ||
                                        photoUrl!.isEmpty ||
                                        (!photoUrl!.startsWith('http') &&
                                            !photoUrl!.startsWith('assets')))
                                    ? Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 20),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          displayName,
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          timeStr,
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['lastMessage'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
