
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/analysis_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  /// Uploads image data (Uint8List) to Firebase Storage and returns the download URL.
  Future<String> uploadImage(Uint8List imageData, String analysisId) async {
    try {
      if (currentUser == null) throw Exception("User not logged in");
      final String userId = currentUser!.uid;
      final ref =
          _storage.ref().child('user_scans').child(userId).child('$analysisId.jpg');

      // Use putData for web and mobile compatibility
      final uploadTask = await ref.putData(imageData);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      rethrow; // Rethrow to let the UI handle it
    }
  }

  /// Saves a new skin analysis result to Firestore.
  Future<void> saveAnalysis(AnalysisResult result) async {
    try {
      if (currentUser == null) throw Exception("User not logged in");
      final docRef = _db.collection('analyses').doc(result.id);
      await docRef.set(result.toJson());
    } catch (e) {
      print("Error saving analysis: $e");
      rethrow; // Rethrow to be caught by the UI
    }
  }

  /// Retrieves a stream of analysis results for the current user.
  Stream<List<AnalysisResult>> getAnalysesStream() {
    if (currentUser == null) return Stream.value([]);

    return _db
        .collection('analyses')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnalysisResult.fromJson(doc.data()))
          .toList();
    });
  }

  /// Deletes a specific analysis result from Firestore and the corresponding image from Storage.
  Future<void> deleteAnalysis(String analysisId, String imageUrl) async {
    try {
      if (currentUser == null) throw Exception("User not logged in");

      // Delete the document from Firestore
      await _db.collection('analyses').doc(analysisId).delete();

      // Delete the image from Firebase Storage
      if (imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print("Error deleting analysis: $e");
      rethrow;
    }
  }
}
