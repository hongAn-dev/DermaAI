import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// 1. Import Zego Cloud
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Import your utility files

import 'package:flutter_linkify/flutter_linkify.dart'; // Import Linkify
import 'package:url_launcher/url_launcher.dart'; // Import URL Launcher
import 'package:myapp/utils/responsive.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // Import Emoji Picker
import '../../services/realtime_service.dart'; // For chatId helper only
import '../../data/models/doctor_model.dart';
import '../../view_models/chat_view_model.dart';

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
  bool _isEditMode = false; // Add edit mode state

  final List<_Message> _messages = [];
  Stream<DatabaseEvent>? _messagesStream;
  bool _showEmoji = false;
  final FocusNode _focusNode = FocusNode();

  // Sidebar Search State
  final TextEditingController _sidebarSearchController =
      TextEditingController();
  String _sidebarSearchQuery = '';

  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String currentUserName = 'User';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      currentUserName = user.displayName!;
    }

    // Ensure user exists in RTDB (Migration/Safety check)
    // We can move this to Repository/ViewModel later or keep it here as a side effect
    // For now, let's keep it simple and maybe skip it or call a repo method if exposed.
    // The ViewModel doesn't explicitly have ensureUser, but it's a one-time check.
    // Let's rely on previous logic or just skip for now to focus on messaging.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChatListener();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
  }

  void _initChatListener() {
    final viewModel = context.read<ChatViewModel>();
    final chatId = viewModel.getChatId(currentUid, widget.doctor.uid);

    _messagesStream = viewModel.getMessagesStream(chatId);
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
        final type = val['type']?.toString() ?? 'text';
        final imageUrl = val['url']?.toString() ??
            val['imageUrl']?.toString() ??
            val['fileUrl']?.toString(); // Handle different keys
        final key = child.key ?? '';

        loaded.add(_Message(
            key: key,
            text: text,
            isMe: isMe,
            time: timeStr,
            senderId: senderId,
            type: type,
            imageUrl: imageUrl));
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
  void dispose() {
    _controller.dispose();
    _sidebarSearchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FD), // Light blue background
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Cuộc trò chuyện',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: Responsive.fontSize(context, 20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _startVideoCall,
            icon: const Icon(Icons.videocam, color: Colors.blue),
          ),
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit,
                color: _isEditMode ? Colors.green : Colors.grey),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Xóa cuộc trò chuyện"),
                    content: const Text(
                        "Bạn có chắc chắn muốn xóa toàn bộ cuộc trò chuyện này? hành động này không thể hoàn tác."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Hủy")),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Xóa",
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  final chatId =
                      RealtimeService.chatId(currentUid, widget.doctor.uid);
                  // Delete for self
                  await FirebaseDatabase.instance
                      .ref('user_chats/$currentUid/$chatId')
                      .remove();
                  // Delete global chat (optional, usually apps just delete ref)
                  // But here user asked to delete conversation
                  // Let's delete for self first to hide it.
                  // If we want to delete for both, we need to delete 'chats/$chatId'

                  // Delete message history
                  await FirebaseDatabase.instance.ref('chats/$chatId').remove();

                  // Delete for other user if needed (optional)
                  if (widget.doctor.uid.isNotEmpty) {
                    await FirebaseDatabase.instance
                        .ref('user_chats/${widget.doctor.uid}/$chatId')
                        .remove();
                  }

                  if (mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa cuộc trò chuyện',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_showEmoji) {
            setState(() {
              _showEmoji = false;
            });
            return false;
          }
          return true;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop/Tablet View
              return Row(
                children: [
                  Container(
                    width: 300, // Increased width as requested
                    child: _buildSidebar(context),
                  ),
                  Expanded(
                    child: _buildChatArea(context),
                  ),
                ],
              );
            } else {
              // Mobile View
              return _buildChatArea(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _sidebarSearchController,
              onChanged: (value) {
                setState(() {
                  _sidebarSearchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _sidebarSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _sidebarSearchController.clear();
                            _sidebarSearchQuery = '';
                            _focusNode
                                .requestFocus(); // Ensure focus returns to text field
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('user_chats/$currentUid')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Text('Chưa có tin nhắn',
                        style: GoogleFonts.manrope(color: Colors.grey)),
                  );
                }

                final data =
                    snapshot.data!.snapshot.value as Map<Object?, Object?>;
                // Convert map to list and sort by timestamp desc
                final List<Map<String, dynamic>> chats = [];
                data.forEach((key, value) {
                  final v = value as Map<Object?, Object?>;
                  chats.add(v.cast<String, dynamic>());
                });

                // Filter Logic
                final filteredChats = chats.where((chat) {
                  final otherName =
                      (chat['otherName'] as String?)?.toLowerCase() ?? '';
                  final lastMsg =
                      (chat['lastMessage'] as String?)?.toLowerCase() ?? '';
                  return otherName.contains(_sidebarSearchQuery) ||
                      lastMsg.contains(_sidebarSearchQuery);
                }).toList();

                filteredChats.sort((a, b) => (b['timestamp'] as int? ?? 0)
                    .compareTo(a['timestamp'] as int? ?? 0));

                if (filteredChats.isEmpty) {
                  return Center(
                      child: Text('Không tìm thấy kết quả',
                          style: GoogleFonts.manrope(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final otherName = chat['otherName'] ?? 'Unknown';
                    final lastMsg = chat['lastMessage'] ?? '';
                    final otherImage =
                        chat['otherImage'] as String?; // Get image

                    final ts = chat['timestamp'] as int? ?? 0;
                    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
                    final timeStr =
                        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: (otherImage != null &&
                                otherImage.isNotEmpty &&
                                otherImage.startsWith('http'))
                            ? NetworkImage(otherImage)
                            : null,
                        child: (otherImage == null ||
                                otherImage.isEmpty ||
                                !otherImage.startsWith('http'))
                            ? Image.asset('assets/images/doctor_avatar.png',
                                fit: BoxFit.cover)
                            : null,
                      ),
                      title: Text(otherName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(lastMsg,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(timeStr,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10)),
                      selected: chat['chatId'] ==
                          RealtimeService.chatId(currentUid, widget.doctor.uid),
                      selectedTileColor: Colors.blue.withOpacity(0.05),
                      onTap: () {
                        // Switch chat
                        final did = chat['otherId'] as String? ?? '';
                        if (did == widget.doctor.uid) return; // already active

                        final dName = chat['otherName'] ?? 'Unknown';
                        final dImage =
                            chat['otherImage']; // get image if available

                        final newDoctor = Doctor(
                            uid: did,
                            name: dName,
                            imagePath: dImage ?? '',
                            specialization: 'General', // Default
                            rating: 0,
                            reviewCount: 0,
                            nextAvailable: 'Now');

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatScreen(doctor: newDoctor)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(BuildContext context) {
    return Column(
      children: [
        // Chat Header specifically for Desktop could go here if needed, but we used the global AppBar
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'Bắt đầu cuộc trò chuyện',
                    style: GoogleFonts.manrope(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, idx) {
                    final msg = _messages[idx];
                    return _buildMessageBubble(msg);
                  },
                ),
        ),
        Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isUploading) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text("Đang gửi...",
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        _buildInputArea(context),
        if (_showEmoji) _buildEmojiPicker(),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _controller.text = _controller.text + emoji.emoji;
        },
        // config: Config(...), // Removing Config to avoid undefined name error
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                backgroundImage: (widget.doctor.imagePath.startsWith('http') ||
                        widget.doctor.imagePath.startsWith('assets'))
                    ? (widget.doctor.imagePath.startsWith('http')
                        ? NetworkImage(widget.doctor.imagePath)
                        : AssetImage(widget.doctor.imagePath) as ImageProvider)
                    : null,
                child: (widget.doctor.imagePath.trim().isEmpty ||
                        (widget.doctor.imagePath.startsWith('http') == false &&
                            widget.doctor.imagePath.startsWith('assets') ==
                                false))
                    ? Image.asset('assets/images/doctor_avatar.png',
                        fit: BoxFit.cover)
                    : null,
              ),
            ),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 4),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Hôm nay',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])))),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF18A0FB) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.type == 'image' && msg.imageUrl != null)
                      GestureDetector(
                        onTap: () {
                          // Expand image logic could go here
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            msg.imageUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: 200,
                                color: Colors.grey[200],
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Text('Lỗi ảnh',
                                    style: TextStyle(color: Colors.red)),
                              );
                            },
                          ),
                        ),
                      )
                    else if (msg.type == 'file')
                      GestureDetector(
                        onTap: () => _launchURL(msg.imageUrl),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.insert_drive_file,
                                  color: Colors.blue, size: 30),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                    msg.text.replaceFirst('[Tệp tin] ', ''),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )
                            ],
                          ),
                        ),
                      )
                    else
                      Linkify(
                        onOpen: (link) => _launchURL(link.url),
                        text: msg.text,
                        style: GoogleFonts.manrope(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        linkStyle: TextStyle(
                            color: isMe ? Colors.white : Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                  ],
                ),
              ),
              if (_isEditMode && isMe)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (msg.type == 'text') // Only allow editing text
                      IconButton(
                        icon: Icon(Icons.edit, size: 16, color: Colors.grey),
                        onPressed: () => _showEditDialog(msg),
                      ),
                    IconButton(
                      icon:
                          Icon(Icons.delete, size: 16, color: Colors.red[300]),
                      onPressed: () => _showDeleteDialog(msg),
                    )
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.done_all,
                          size: 14, color: Colors.blue[300]),
                    )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: _pickAnyFile, // Changed to pick any file
              child: Icon(Icons.add_circle_outline,
                  color: Colors.grey[600], size: 28),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _pickImage, // Call pick image
              child:
                  Icon(Icons.image_outlined, color: Colors.grey[600], size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: GoogleFonts.manrope(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showEmoji
                            ? Icons.keyboard
                            : Icons.sentiment_satisfied_alt,
                        color: Colors.grey[500]),
                    onPressed: () {
                      setState(() {
                        _showEmoji = !_showEmoji;
                        if (_showEmoji) {
                          _focusNode.unfocus();
                        } else {
                          // Slight delay to ensure UI rebuilds before requesting focus
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) _focusNode.requestFocus();
                          });
                        }
                      });
                    },
                  ),
                ),
                focusNode: _focusNode,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF18A0FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 24),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _showEmoji = false;
    });

    final viewModel = context.read<ChatViewModel>();
    final chatId = viewModel.getChatId(currentUid, widget.doctor.uid);

    await viewModel.sendMessage(
      chatId: chatId,
      text: text,
      senderId: currentUid,
      otherId: widget.doctor.uid,
      myName: currentUserName,
      otherName: widget.doctor.name,
      otherImage: widget.doctor.imagePath,
    );
  }

  Future<void> _pickImage() async {
    final viewModel = context.read<ChatViewModel>();
    final chatId = viewModel.getChatId(currentUid, widget.doctor.uid);

    await viewModel.sendImage(
      chatId: chatId,
      senderId: currentUid,
      otherId: widget.doctor.uid,
      myName: currentUserName,
      otherName: widget.doctor.name,
      otherImage: widget.doctor.imagePath,
    );
  }

  Future<void> _pickAnyFile() async {
    final viewModel = context.read<ChatViewModel>();
    final chatId = viewModel.getChatId(currentUid, widget.doctor.uid);

    await viewModel.sendFile(
      chatId: chatId,
      senderId: currentUid,
      otherId: widget.doctor.uid,
      myName: currentUserName,
      otherName: widget.doctor.name,
      otherImage: widget.doctor.imagePath,
    );
  }

  // --- Helpers ---
  Future<void> _launchURL(String? urlString) async {
    if (urlString == null) return;
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Không thể mở file")));
      }
    } catch (e) {
      debugPrint("Link error: $e");
    }
  }

  void _showEditDialog(_Message msg) {
    if (msg.key.isEmpty) return;
    final editCtrl = TextEditingController(text: msg.text);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Sửa tin nhắn"),
              content: TextField(controller: editCtrl),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // TODO: Implement updateMessage in ViewModel
                      // final newText = editCtrl.text.trim();
                      // if (newText.isNotEmpty && newText != msg.text) {
                      //   final viewModel = context.read<ChatViewModel>();
                      //   await viewModel.updateMessage(...)
                      // }
                    },
                    child: Text("Lưu")),
              ],
            ));
  }

  void _showDeleteDialog(_Message msg) {
    if (msg.key.isEmpty) return;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Xác nhận xóa"),
              content: Text("Bạn có chắc chắn muốn xóa tin nhắn này?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final viewModel = context.read<ChatViewModel>();
                      final chatId =
                          viewModel.getChatId(currentUid, widget.doctor.uid);
                      await viewModel.deleteMessage(chatId, msg.key);
                    },
                    child: Text("Xóa", style: TextStyle(color: Colors.red))),
              ],
            ));
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String time;
  final String senderId;
  final String type;
  final String? imageUrl;
  final String key; // Add key

  _Message(
      {required this.text,
      required this.isMe,
      required this.time,
      this.senderId = '',
      this.type = 'text',
      this.imageUrl,
      this.key = ''});
}
