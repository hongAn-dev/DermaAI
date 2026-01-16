import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/realtime_service.dart';
import '../../services/upload_service.dart';

class ChatRepository {
  final RealtimeService _realtimeService = RealtimeService();
  final UploadService _uploadService = UploadService();

  // Stream of messages for a specific chat room
  Stream<DatabaseEvent> getMessages(String chatId, {int? startAt}) {
    return _realtimeService.messagesStream(chatId, startAt: startAt);
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required Map<String, dynamic> messageData,
    String? myName,
    String? otherName,
    String? otherImage,
  }) async {
    await _realtimeService.sendMessage(
      chatId,
      messageData,
      myName: myName,
      otherName: otherName,
      otherImage: otherImage,
    );
  }

  // Upload an image
  Future<String?> uploadImage(XFile imageFile) async {
    return await _uploadService.uploadImage(imageFile);
  }

  // Upload raw bytes (for files) - assuming UploadService has uploadFile for bytes
  Future<String?> uploadFile(Uint8List bytes, String filename) async {
    return await _uploadService.uploadFile(bytes, filename);
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _realtimeService.deleteMessage(chatId, messageId);
  }
}
