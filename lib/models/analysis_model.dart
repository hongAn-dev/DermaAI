
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisResult {
  final String id;
  final String userId;
  final String disease;
  final double probability;
  final String recommendation;
  final String imageUrl;
  final DateTime timestamp;

  AnalysisResult({
    required this.id,
    required this.userId,
    required this.disease,
    required this.probability,
    required this.recommendation,
    required this.imageUrl,
    required this.timestamp,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      userId: json['userId'] as String,
      disease: json['disease'] as String,
      probability: (json['probability'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      imageUrl: json['imageUrl'] as String,
      // Handle both Timestamp (from Firestore) and String (from RTDB)
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'disease': disease,
      'probability': probability,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
      // Store as ISO 8601 string for Realtime Database compatibility
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
