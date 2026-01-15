class Doctor {
  final String name;
  final String specialization;
  final String uid;
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
}
