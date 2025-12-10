
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisResult {
  final String id;
  final String userId; // Add this field
  final String disease;
  final double probability;
  final String recommendation;
  final String imageUrl;
  final DateTime timestamp;

  AnalysisResult({
    required this.id,
    required this.userId, // Add this to the constructor
    required this.disease,
    required this.probability,
    required this.recommendation,
    required this.imageUrl,
    required this.timestamp,
  });

  // Factory constructor to create an AnalysisResult from a JSON object (from Firestore)
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      userId: json['userId'] as String, // Read the userId
      disease: json['disease'] as String,
      probability: (json['probability'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert an AnalysisResult instance to a JSON object (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // Add userId to the JSON object
      'disease': disease,
      'probability': probability,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
