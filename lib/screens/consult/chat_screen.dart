import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// 1. Import Zego Cloud
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Import your utility files
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/utils/responsive.dart';
import '../../services/appearance_model.dart';
import '../../services/realtime_service.dart';
import 'consult_screen.dart';

// --- ZEGOCLOUD CONFIGURATION ---
const int yourAppID = 971082061; // <-- Replace with your real App ID
const String yourAppSign =
    'f4cbc28dd585f858977af5273778ac05a1abd15b431191f18d607f0cd1bd201f'; // <-- Replace with your real App Sign
// --------------------------

class ChatScreen extends StatefulWidget {
  final Doctor doctor;
  const ChatScreen({super.key, required this.doctor});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Message> _messages = [];
  late final RealtimeService _realtime;
  Stream<DatabaseEvent>? _messagesStream;

  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String currentUserName = 'User';

  @override
  void initState() {
    super.initState();
    _realtime = RealtimeService();

    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      currentUserName = user.displayName!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChatListener();
    });
  }

  Future<void> _initChatListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _realtime.ensureUser(currentUid, {
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'user'
      });
    } catch (e) {
      debugPrint("Error ensuring user: $e");
    }

    final chatId = RealtimeService.chatId(currentUid, widget.doctor.uid);
    _messagesStream = _realtime.messagesStream(chatId);
    _messagesStream!.listen((event) {
      final snapshot = event.snapshot;
      final kids = snapshot.children;
      final List<_Message> loaded = [];

      for (final child in kids) {
        final val = child.value as Map<Object?, Object?>?;
        if (val == null) continue;

        final text = val['text']?.toString() ?? '';
        final senderId = val['senderId']?.toString() ?? '';

        final tsRaw = val['timestamp'];
        String timeStr = '';
        if (tsRaw is int) {
          final dt = DateTime.fromMillisecondsSinceEpoch(tsRaw);
          timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
        } else {
          timeStr = tsRaw?.toString() ?? '';
        }

        final isMe = (senderId == currentUid);
        loaded.add(_Message(
            text: text, isMe: isMe, time: timeStr, senderId: senderId));
      }

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(loaded);
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scroll.hasClients) {
            _scroll.animateTo(_scroll.position.maxScrollExtent + 100,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        });
      }
    });
  }

  // --- HÀM GỌI VIDEO (WEB SAFE - VERSION 3) ---
  void _startVideoCall() {
    final callID = RealtimeService.chatId(currentUid, widget.doctor.uid);

    ZegoUIKitPrebuiltCallConfig config;

    if (kIsWeb) {
      // WEB: Cấu hình tối giản để tránh crash
      config = ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        ..bottomMenuBar.buttons = [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchCameraButton,
        ]
        ..topMenuBar.buttons = [
          ZegoMenuBarButtonName.showMemberListButton,
        ];

      // Disable avatar to prevent potential image loading issues
      config.avatarBuilder = null;
    } else {
      // MOBILE: Full tính năng
      config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..bottomMenuBar.buttons = [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
          ZegoMenuBarButtonName.switchCameraButton,
        ]
        ..topMenuBar.buttons = [
          ZegoMenuBarButtonName.showMemberListButton,
        ];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SafeArea(
            child: ZegoUIKitPrebuiltCall(
              appID: yourAppID,
              appSign: yourAppSign,
              userID: currentUid,
              userName: currentUserName,
              callID: callID,
              config: config,
            ),
          );
        },
      ),
    );
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    final appearance = Provider.of<AppearanceModel>(context);
    final accent = Color(appearance.accentColorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            CircleAvatar(
              radius: Responsive.avatarRadius(context, base: 18),
              backgroundColor: Colors.grey[200],
              backgroundImage: widget.doctor.imagePath.isNotEmpty
                  ? NetworkImage(widget.doctor.imagePath)
                  : null,
              child: widget.doctor.imagePath.isEmpty
                  ? Text(widget.doctor.name.isNotEmpty
                      ? widget.doctor.name[0]
                      : '?')
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctor.name.split(',').first,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: Responsive.fontSize(context, 16))),
                Text('Đang hoạt động',
                    style: GoogleFonts.manrope(
                        color: accent,
                        fontSize: Responsive.fontSize(context, 12))),
              ],
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _startVideoCall,
              icon: Icon(Icons.videocam, color: accent)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.grey)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: Responsive.scale(context, 64),
                            color: Colors.grey[400]),
                        SizedBox(height: Responsive.scale(context, 12)),
                        Text('Chưa có tin nhắn',
                            style: GoogleFonts.manrope(
                                color: Colors.grey[600],
                                fontSize: Responsive.fontSize(context, 16))),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final alignment = msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      final bgColor = msg.isMe ? accent : Colors.grey[200];
                      final textColor = msg.isMe ? Colors.white : Colors.black;

                      if (msg.text == '<image>') {
                        return Align(
                          alignment: alignment,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: Responsive.scale(context, 180),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: accent, width: 4)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(color: Colors.amberAccent)),
                          ),
                        );
                      }
                      return Align(
                        alignment: alignment,
                        child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.72),
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.scale(context, 16),
                                vertical: Responsive.scale(context, 12)),
                            margin: EdgeInsets.symmetric(
                                vertical: Responsive.scale(context, 8)),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(msg.isMe ? 16 : 0),
                                bottomRight: Radius.circular(msg.isMe ? 0 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: colorWithOpacity(Colors.grey, 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(msg.text,
                                      style: GoogleFonts.manrope(
                                          color: textColor,
                                          fontSize: Responsive.fontSize(
                                              context, 16))),
                                  SizedBox(
                                      height: Responsive.scale(context, 6)),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(msg.time,
                                            style: GoogleFonts.manrope(
                                                color: msg.isMe
                                                    ? Colors.white
                                                        .withOpacity(0.7)
                                                    : Colors.grey[600],
                                                fontSize: Responsive.fontSize(
                                                    context, 11))),
                                        if (msg.isMe) ...[
                                          SizedBox(
                                              width:
                                                  Responsive.scale(context, 6)),
                                          Icon(Icons.done_all,
                                              size:
                                                  Responsive.scale(context, 14),
                                              color: Colors.white70)
                                        ]
                                      ])
                                ])),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.grey)),
                  IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.image_outlined, color: Colors.grey)),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.scale(context, 12)),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: GoogleFonts.manrope(
                                color: Colors.grey[500],
                                fontSize: Responsive.fontSize(context, 14))),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.scale(context, 8)),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: accent,
                    mini: true,
                    child: const Icon(Icons.send, color: Colors.white),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final chatId = RealtimeService.chatId(user.uid, widget.doctor.uid);
    final message = {
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? '',
      'otherId': widget.doctor.uid,
      'timestamp': ServerValue.timestamp,
      'type': 'text',
    };
    await _realtime.sendMessage(chatId, message);
    _controller.clear();
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String time;
  final String senderId;
  _Message(
      {required this.text,
      required this.isMe,
      required this.time,
      this.senderId = ''});
}
