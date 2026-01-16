import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/realtime_service.dart';
import '../../services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RealtimeService _realtimeService = RealtimeService();
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phoneNumber,
    String? birthDate,
    String? gender,
    String? address,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(displayName.trim());

      final userData = {
        'displayName': displayName.trim(),
        'email': user.email ?? email,
        'role': role,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (birthDate != null) 'birthDate': birthDate,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
      };

      // Sync to Realtime DB
      await _realtimeService.ensureUser(user.uid, userData);

      // Sync to Firestore
      await _firestoreService.ensureUserDoc(user.uid, {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<bool> isPhoneNumberTaken(String phoneNumber) async {
    return await _firestoreService.checkPhoneNumberExists(phoneNumber.trim());
  }
}
