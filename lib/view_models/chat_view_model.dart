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
  Stream<DatabaseEvent> getMessagesStream(String chatId) {
    return _chatRepository.getMessages(chatId);
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
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      _setUploading(true);
      try {
        final fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;

        if (fileBytes != null) {
          final fileUrl = await _chatRepository.uploadFile(fileBytes, fileName);
          if (fileUrl != null) {
            final messageData = {
              'senderId': senderId,
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
