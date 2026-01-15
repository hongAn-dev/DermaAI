import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/analysis_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'scan_history';

  User? get currentUser => _auth.currentUser;

  /// Saves raw analysis data (as a Map) to the 'scan_history' collection.
  Future<void> saveRawAnalysisResult(
      String docId, Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception("Người dùng chưa đăng nhập");
    try {
      await _db.collection(_collectionName).doc(docId).set(data);
    } catch (e) {
      print("Lỗi khi lưu kết quả phân tích: \$e");
      rethrow;
    }
  }

  /// Retrieves and transforms a stream of analysis results.
  Stream<List<AnalysisResult>> getAnalysesStream() {
    if (currentUser == null) return Stream.value([]);

    return _db
        .collection(_collectionName)
        .where('scanResult.userId', isEqualTo: currentUser!.uid)
        .orderBy('scanResult.timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final scanResult = data['scanResult'] as Map<String, dynamic>? ?? {};
        final prediction =
            scanResult['prediction'] as Map<String, dynamic>? ?? {};

        final detailsList = (scanResult['details'] as List<dynamic>?)
                ?.map((d) => d as Map<String, dynamic>)
                .toList() ??
            [];

        return AnalysisResult(
          id: doc.id,
          userId: scanResult['userId'] as String? ?? '',
          disease: prediction['className'] as String? ?? 'N/A',
          probability:
              (prediction['confidenceScore'] as num?)?.toDouble() ?? 0.0,
          recommendation: "Tham khảo ý kiến bác sĩ da liễu để được chẩn đoán chuyên môn.",
          imageUrl: data['imagePath'] as String? ?? '', // Will be empty
          timestamp: (scanResult['timestamp'] as Timestamp? ?? Timestamp.now())
              .toDate(),
          details: detailsList.map((d) => DiseaseDetail.fromJson(d)).toList(),
        );
      }).toList();
    });
  }

  /// Deletes a specific analysis result from Firestore.
  Future<void> deleteAnalysis(String analysisId) async {
    if (currentUser == null) throw Exception("User not logged in");
    try {
      // Only delete the document from Firestore.
      await _db.collection(_collectionName).doc(analysisId).delete();
    } catch (e) {
      print("Error deleting analysis: \$e");
      rethrow;
    }
  }

  /// Ensure a user document exists in Firestore under `users/{uid}`
  Future<void> ensureUserDoc(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error writing user doc: $e');
      rethrow;
    }
  }
}
