import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Query;
import 'package:go_router/go_router.dart'; // Đừng quên import package này
import 'package:myapp/utils/responsive.dart';
import 'chat_screen.dart';
import '../../models/doctor.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _editing = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tin nhắn...',
                  border: InputBorder.none,
                ),
                style: GoogleFonts.manrope(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text('Cuộc trò chuyện',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 20),
                    color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          if (!_isSearching)
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
            final isWide = Responsive.deviceType(context) != DeviceType.mobile;

            if (isWide) {
              return Row(
                children: [
                  // Left side: Chat List (constrained width)
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: _buildChatList(ref),
                  ),
                  // Right side: Welcome Panel
                  Expanded(
                    child: _buildWelcomePanel(),
                  ),
                ],
              );
            } else {
              // Mobile: Full width chat list
              return _buildChatList(ref);
            }
          },
        ),
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

  Widget _buildChatList(Query ref) {
    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Lỗi: ${snap.error}'));
        }
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 80, color: Colors.grey[300]),
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
        final map = snap.data!.snapshot.value as Map<Object?, Object?>;
        final list = map.entries.map((e) {
          final v = e.value as Map<Object?, Object?>;
          return {
            'chatId': v['chatId'] ?? e.key,
            'otherId': v['otherId'] ?? '',
            'lastMessage': v['lastMessage'] ?? '',
            'timestamp': v['timestamp'] ?? 0,
          };
        }).toList();

        // Filter list
        final filteredList = list.where((item) {
          final lastMessage = (item['lastMessage'] as String).toLowerCase();
          return lastMessage.contains(_searchQuery);
        }).toList()
          ..sort((a, b) =>
              (b['timestamp'] as int).compareTo(a['timestamp'] as int));

        if (filteredList.isEmpty) {
          return Center(
              child: Text('Không tìm thấy cuộc trò chuyện nào',
                  style: GoogleFonts.manrope(color: Colors.grey)));
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
              vertical: Responsive.scale(context, 16), horizontal: 16),
          itemCount: filteredList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final item = filteredList[idx];
            final chatId = item['chatId'] as String;
            final otherId = item['otherId'] as String;
            final timestamp = item['timestamp'] as int;
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final timeStr =
                "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

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
                    // Xóa từ Firebase
                    await FirebaseDatabase.instance
                        .ref('chats/$chatId')
                        .remove();
                    await FirebaseDatabase.instance
                        .ref('user_chats/${user!.uid}/$chatId')
                        .remove();
                    if (otherId.isNotEmpty) {
                      await FirebaseDatabase.instance
                          .ref('user_chats/$otherId/$chatId')
                          .remove();
                    }
                    // setState không cần thiết nếu dùng StreamBuilder, nhưng giữ để update UI ngay lập tức
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
                          onTap: _editing
                              ? null
                              : () async {
                                  final doctorDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(otherId)
                                      .get();
                                  final d = doctorDoc.data();
                                  final partner = Doctor(
                                      uid: otherId,
                                      name: d?['displayName'] as String? ??
                                          otherId,
                                      specialization:
                                          'Patient', // or check role
                                      rating: 0.0,
                                      reviewCount: 0,
                                      nextAvailable: '',
                                      imagePath:
                                          d?['photoUrl'] as String? ?? '');

                                  if (!context.mounted) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          ChatScreen(doctor: partner)));
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blue.shade50,
                                  backgroundImage:
                                      photoUrl != null && photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : null,
                                  child: photoUrl == null
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
          },
        );
      },
    );
  }
}
