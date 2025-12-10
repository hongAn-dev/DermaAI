import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/analysis_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAnalysisResult(AnalysisResult result) async {
    final user = _auth.currentUser;
    if (user != null) {
      final newResultRef = _database.ref('history/${user.uid}').push();
      await newResultRef.set(result.toJson());
    }
  }

  Stream<List<AnalysisResult>> getAnalysisHistory() {
    final user = _auth.currentUser;
    if (user != null) {
      final historyRef = _database.ref('history/${user.uid}');
      return historyRef.onValue.map((event) {
        final List<AnalysisResult> results = [];
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            results.add(AnalysisResult.fromJson(Map<String, dynamic>.from(value as Map)));
          });
        }
        return results;
      });
    }
    return Stream.value([]);
  }
}
