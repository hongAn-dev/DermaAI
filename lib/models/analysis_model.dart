import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// PART 1: Models for handling API Response
// ==========================================

class AnalysisResponse {
  final Prediction prediction;
  final List<DiseaseDetail> details;
  final String heatmapImage;

  AnalysisResponse({
    required this.prediction,
    required this.details,
    required this.heatmapImage,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<DiseaseDetail> details =
        detailsList.map((i) => DiseaseDetail.fromJson(i)).toList();

    return AnalysisResponse(
      prediction: Prediction.fromJson(json['prediction']),
      details: details,
      heatmapImage: json['heatmap_image'] as String,
    );
  }
}

class Prediction {
  final String className;
  final String confidence;

  Prediction({required this.className, required this.confidence});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      // Key trả về từ API, thường là 'class' hoặc 'class_name'
      className: json['class'] as String,
      confidence: json['confidence'] as String,
    );
  }
}

class DiseaseDetail {
  final String disease;
  final double probability;

  DiseaseDetail({required this.disease, required this.probability});

  factory DiseaseDetail.fromJson(Map<String, dynamic> json) {
    return DiseaseDetail(
      disease: json['disease'] as String,
      probability: (json['probability'] as num).toDouble(),
    );
  }

  // Helper để convert sang JSON khi lưu xuống Firestore
  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'probability': probability,
    };
  }
}

// ==========================================
// PART 2: Model for storing data in Firestore
// ==========================================

class AnalysisResult {
  final String id;
  final String userId;
  final String disease;
  final double probability;
  final String recommendation;
  final String imageUrl;
  final DateTime timestamp;
  final List<DiseaseDetail> details; // Sử dụng List object thay vì List Map

  AnalysisResult({
    required this.id,
    required this.userId,
    required this.disease,
    required this.probability,
    required this.recommendation,
    required this.imageUrl,
    required this.timestamp,
    required this.details,
  });

  // Chuyển từ JSON Firestore về Object
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      disease: json['disease'] as String? ?? 'Unknown',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // Convert từ List<dynamic> trong Firestore sang List<DiseaseDetail>
      details: json['details'] != null
          ? (json['details'] as List)
              .map((i) => DiseaseDetail.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  // Chuyển từ Object sang JSON để lưu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'disease': disease,
      'probability': probability,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),

      // Tự động convert từng object DiseaseDetail sang JSON
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}
