class Doctor {
  final String uid;
  final String name;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String nextAvailable;
  final String imagePath;

  Doctor({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.nextAvailable,
    required this.imagePath,
  });

  // Helper to create Doctor from Firestore Document
  factory Doctor.fromMap(String uid, Map<String, dynamic> data) {
    return Doctor(
      uid: uid,
      name: data['displayName'] ?? 'Unknown Doctor',
      specialization: data['specialization'] ?? 'General',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: data['reviewCount'] ?? 0,
      nextAvailable: data['nextAvailable'] ?? 'Available now',
      imagePath: data['photoUrl'] ?? 'assets/images/doctor_avatar.png',
    );
  }
}
