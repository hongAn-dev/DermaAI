import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? dateOfBirth; // DD/MM/YYYY
  final String? gender;
  final String? photoUrl;
  final String? address;
  final String role; // 'user' or 'doctor' or 'admin'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.address,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      fullName:
          data['fullName'] ?? data['displayName'] ?? '', // Fallback for legacy
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'] ?? data['birthDate'], // Fallback
      gender: data['gender'],
      photoUrl: data['photoUrl'],
      address: data['address'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'photoUrl': photoUrl,
      'address': address,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
