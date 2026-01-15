import 'package:firebase_database/firebase_database.dart';

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

  Stream<DatabaseEvent> messagesStream(String chatId) {
    return _db.ref('chats/$chatId/messages').orderByChild('timestamp').onValue;
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> message,
      {String? otherName, String? otherImage, String? myName}) async {
    final ref = _db.ref('chats/$chatId/messages').push();
    await ref.set(message);
    // also update per-user chat index for quick conversation list
    try {
      final senderId = message['senderId']?.toString() ?? '';
      final otherId = message['otherId']?.toString() ?? '';
      final timestamp = message['timestamp'] ?? ServerValue.timestamp;

      if (senderId.isNotEmpty) {
        final updateData = {
          'chatId': chatId,
          'otherId': otherId,
          'lastMessage': message['text'] ?? '',
          'timestamp': timestamp,
        };
        if (otherName != null) updateData['otherName'] = otherName;
        if (otherImage != null) updateData['otherImage'] = otherImage;

        await _db.ref('user_chats/$senderId/$chatId').update(updateData);
      }
      if (otherId.isNotEmpty) {
        final updateData = {
          'chatId': chatId,
          'otherId': senderId,
          'lastMessage': message['text'] ?? '',
          'timestamp': timestamp,
        };
        // For the other person, 'otherName' is MY name
        if (myName != null) updateData['otherName'] = myName;

        await _db.ref('user_chats/$otherId/$chatId').update(updateData);
      }
    } catch (e) {
      // non-fatal
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
