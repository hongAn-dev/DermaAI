import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;

  DoctorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Doctor>> getDoctorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        return Doctor.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
