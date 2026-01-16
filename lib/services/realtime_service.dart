import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class RealtimeService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  static String chatId(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  Future<void> ensureUser(String uid, Map<String, dynamic> data) async {
    final ref = _db.ref('users/$uid');
    try {
      // Use set so the node is created if missing and permissions apply
      await ref.set(data);
    } catch (e) {
      // surface error for callers
      // ignore: avoid_print
      print('RealtimeService.ensureUser error: $e');
      rethrow;
    }
  }

  Stream<DatabaseEvent> messagesStream(String chatId, {int? startAt}) {
    var query = _db.ref('chats/$chatId/messages').orderByChild('timestamp');
    if (startAt != null) {
      return query.startAt(startAt).onValue;
    }
    return query.onValue;
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> message,
      {String? otherName, String? otherImage, String? myName}) async {
    // Robustly update per-user chat index to ensure conversation visibility (even if deleted previously)
    try {
      final senderId = message['senderId']?.toString() ?? '';
      final otherId = message['otherId']?.toString() ??
          ''; // "otherId" relative to the message sender is the Receiver
      final timestamp = message['timestamp'] ?? ServerValue.timestamp;
      final text = message['text'] ??
          (message['type'] == 'image' ? '[Hình ảnh]' : '[Tin nhắn]');

      // 0. Ensure participants node exists (Required for Security Rules)
      // This MUST occur before or concurrently with message write if rules depend on it.
      // However, if we are creating a new chat, rules allow write if !data.exists().
      // If chat exists, we must be a participant.
      if (senderId.isNotEmpty && otherId.isNotEmpty) {
        await _db.ref('chats/$chatId/participants').update({
          senderId: true,
          otherId: true,
        });
      }

      // Now write the message
      final ref = _db.ref('chats/$chatId/messages').push();
      await ref.set(message);

      // 1. Update Sender's Inbox (Me)
      if (senderId.isNotEmpty) {
        debugPrint('Updating SENDER inbox: user_chats/$senderId/$chatId');
        final senderUpdate = {
          'chatId': chatId,
          'otherId': otherId,
          'lastMessage': text,
          'timestamp': timestamp,
        };
        // If we know the receiver's details, save them so the sender sees a nice name immediately
        if (otherName != null && otherName.isNotEmpty)
          senderUpdate['otherName'] = otherName;
        if (otherImage != null && otherImage.isNotEmpty)
          senderUpdate['otherImage'] = otherImage;

        await _db.ref('user_chats/$senderId/$chatId').update(senderUpdate);
      } else {
        debugPrint('WARNING: senderId is empty!');
      }

      // 2. Update Receiver's Inbox (Them)
      // For the receiver, the "otherId" is the SENDER (me)
      if (otherId.isNotEmpty) {
        debugPrint('Updating RECEIVER inbox: user_chats/$otherId/$chatId');
        final receiverUpdate = {
          'chatId': chatId,
          'otherId': senderId, // Linking back to me
          'lastMessage': text,
          'timestamp': timestamp,
        };
        // For the receiver, "otherName" is MY name
        if (myName != null && myName.isNotEmpty)
          receiverUpdate['otherName'] = myName;

        // Note: Ideally pass myImage too, but we might not have it readily available here.
        // Logic relies on StreamBuilder fetching user info if missing, but having names helps.

        await _db.ref('user_chats/$otherId/$chatId').update(receiverUpdate);
        debugPrint('RECEIVER inbox updated successfully');
      } else {
        debugPrint(
            'WARNING: otherId (Receiver UID) is empty! Cannot update receiver inbox.');
      }
    } catch (e) {
      print('sendMessage error: $e'); // Log error for debugging
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _db.ref('chats/$chatId/messages/$messageId').remove();
  }

  Future<void> updateMessage(
      String chatId, String messageId, String newText) async {
    await _db.ref('chats/$chatId/messages/$messageId').update({
      'text': newText,
      // optionally mark as edited
      'isEdited': true,
    });
  }
}
