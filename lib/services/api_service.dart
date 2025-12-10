
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// --- Data Models for JSON Response ---

class AnalysisResponse {
  final String status;
  final Prediction prediction;
  final List<DiseaseDetail> details;
  final String heatmapImage; // Base64 encoded string

  AnalysisResponse({
    required this.status,
    required this.prediction,
    required this.details,
    required this.heatmapImage,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<DiseaseDetail> diseaseDetails = detailsList.map((i) => DiseaseDetail.fromJson(i)).toList();

    return AnalysisResponse(
      status: json['status'],
      prediction: Prediction.fromJson(json['prediction']),
      details: diseaseDetails,
      heatmapImage: json['heatmap_image'],
    );
  }
}

class Prediction {
  final String className;
  final String confidence;
  final double confidenceScore;

  Prediction({
    required this.className,
    required this.confidence,
    required this.confidenceScore,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      className: json['class'],
      confidence: json['confidence'],
      confidenceScore: json['confidence_score'].toDouble(),
    );
  }
}

class DiseaseDetail {
  final String disease;
  final double probability;
  final double score;

  DiseaseDetail({
    required this.disease,
    required this.probability,
    required this.score,
  });

  factory DiseaseDetail.fromJson(Map<String, dynamic> json) {
    return DiseaseDetail(
      disease: json['disease'],
      probability: json['probability'].toDouble(),
      score: json['score'].toDouble(),
    );
  }
}

// --- API Service Class ---

class ApiService {
  static const String _baseUrl = 'https://nannette-suppositious-brayan.ngrok-free.dev';

  Future<AnalysisResponse?> analyzeImage(XFile imageFile) async {
    final uri = Uri.parse('$_baseUrl/explain');
    final request = http.MultipartRequest('POST', uri);

    // Read the file as a byte stream to support both web and mobile
    final imageBytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file', // This is the field name the server expects
      imageBytes,
      filename: imageFile.name, // Pass the original filename
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedJson = jsonDecode(responseBody);
        return AnalysisResponse.fromJson(decodedJson);
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Error: Server returned status code ${response.statusCode}');
        print('Error body: $errorBody');
        return null;
      }
    } catch (e) {
      print('Error sending request: $e');
      return null;
    }
  }
}
