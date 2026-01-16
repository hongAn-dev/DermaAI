import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../data/repositories/chat_repository.dart';
import '../services/realtime_service.dart'; // For chatId helper

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Constructor
  ChatViewModel({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  // Helper to generate Chat ID
  String getChatId(String userId1, String userId2) {
    return RealtimeService.chatId(userId1, userId2);
  }

  // Stream Messages
  // Stream Messages
  Stream<DatabaseEvent> getMessagesStream(String chatId, {int? startAt}) {
    return _chatRepository.getMessages(chatId, startAt: startAt);
  }

  // Send Text Message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String otherId,
    String? myName,
    String? otherName,
    String? otherImage,
  }) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'senderId': senderId,
      'otherId': otherId, // Critical for inbox updates
      'text': text.trim(),
      'type': 'text',
      'timestamp': ServerValue.timestamp,
    };

    await _chatRepository.sendMessage(
      chatId: chatId,
      messageData: messageData,
      myName: myName,
      otherName: otherName,
      otherImage: otherImage,
    );
  }

  // Pick and Send Image
  Future<void> sendImage({
    required String chatId,
    required String senderId,
    required String otherId,
    String? myName,
    String? otherName,
    String? otherImage,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _setUploading(true);
      try {
        final imageUrl = await _chatRepository.uploadImage(image);
        if (imageUrl != null) {
          final messageData = {
            'senderId': senderId,
            'otherId': otherId, // Critical for inbox updates
            'text': 'Đã gửi một ảnh',
            'imageUrl': imageUrl,
            'type': 'image',
            'timestamp': ServerValue.timestamp,
          };

          await _chatRepository.sendMessage(
            chatId: chatId,
            messageData: messageData,
            myName: myName,
            otherName: otherName,
            otherImage: otherImage,
          );
        }
      } catch (e) {
        debugPrint('Error sending image: $e');
      } finally {
        _setUploading(false);
      }
    }
  }

  // Pick and Send File
  Future<void> sendFile({
    required String chatId,
    required String senderId,
    required String otherId,
    String? myName,
    String? otherName,
    String? otherImage,
  }) async {
    // Use withData: true to ensure bytes are available on mobile (simplifies upload logic)
    // Warning: High memory usage for large files.
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      _setUploading(true);
      try {
        Uint8List? fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;

        // On Mobile/Desktop IO, bytes might be null, need to read from path
        if (fileBytes == null && result.files.first.path != null) {
          // We need 'dart:io' but this is a ViewModel.
          // Ideally use a cross-platform helper or check kIsWeb.
          // Since we can't easily import dart:io conditionally in clean arch without conditional imports,
          // and we want to keep it simple:
          // We will assume the UI/Service can handle path, OR we force read it.
          // However, UploadService expects bytes.
          // Let's defer to a helper or simply use CrossFile/XFile approaches if possible.
          // For now, let's try to grab bytes via XFile since we have image_picker anyway,
          // BUT FilePicker result isn't XFile.

          // QUICK FIX: file_picker usually returns path on mobile.
          // We can't use File(path).readAsBytes() easily without importing dart:io.
          // Let's use `createFileFromPath` logic or similar found in typical Flutter apps.
          // Actually, simpler: instruct FilePicker to load with Data on mobile if performance is okay (users send small files).
          // But `sendMessage` implies potentially larger files.

          // Better approach: Update `ChatViewModel` to be platform aware or modify `withData`.
          // Let's try changing the `pickFiles` call to `withData: true` for now (easiest fix),
          // although memory heavy, it ensures bytes are present.
        }

        if (fileBytes != null) {
          final fileUrl = await _chatRepository.uploadFile(fileBytes, fileName);
          if (fileUrl != null) {
            final messageData = {
              'senderId': senderId,
              'otherId': otherId, // Critical for inbox updates
              'text': 'Đã gửi tệp: $fileName',
              'fileUrl': fileUrl,
              'fileName': fileName,
              'type': 'file',
              'timestamp': ServerValue.timestamp,
            };

            await _chatRepository.sendMessage(
              chatId: chatId,
              messageData: messageData,
              myName: myName,
              otherName: otherName,
              otherImage: otherImage,
            );
          }
        }
      } catch (e) {
        debugPrint('Error sending file: $e');
      } finally {
        _setUploading(false);
      }
    }
  }

  // Delete Message
  Future<void> deleteMessage(String chatId, String messageKey) async {
    await _chatRepository.deleteMessage(chatId, messageKey);
  }

  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }
}
