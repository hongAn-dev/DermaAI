
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the centralized data models instead of defining them here
import 'package:myapp/models/analysis_model.dart';

// --- API Service Class ---

class ApiService {
  // NOTE: This Ngrok URL is temporary. For production, you should use a permanent server URL.
  static const String _baseUrl = 'https://nannette-suppositious-brayan.ngrok-free.dev';

  /// Analyzes an image by sending it to the backend server.
  ///
  /// The [imageFile] is sent as a multipart request to the /explain endpoint.
  /// It returns an [AnalysisResponse] object if successful, otherwise null.
  Future<AnalysisResponse?> analyzeImage(XFile imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Throwing an exception is better for handling this case in the UI.
      throw Exception("User is not authenticated. Cannot analyze image.");
    }
    final userId = user.uid;

    final uri = Uri.parse('$_baseUrl/explain');
    final request = http.MultipartRequest('POST', uri);

    final imageBytes = await imageFile.readAsBytes();
    
    // Create a unique filename for the image to avoid potential conflicts.
    final imageName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';

    final multipartFile = http.MultipartFile.fromBytes(
      'file', 
      imageBytes,
      filename: imageName,
    );

    request.files.add(multipartFile);
    // You can add more fields to the request if your backend needs them, e.g.:
    // request.fields['userId'] = userId;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedJson = jsonDecode(responseBody);
        // Now uses the model from analysis_model.dart
        return AnalysisResponse.fromJson(decodedJson);
      } else {
        final errorBody = await response.stream.bytesToString();
        // Providing more specific error information is helpful for debugging.
        throw Exception('Server Error ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      // Log the error and re-throw to allow the UI to handle it.
      print('Error in analyzeImage: $e');
      rethrow;
    }
  }
}
