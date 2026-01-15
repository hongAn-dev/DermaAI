import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class UploadService {
  // Manual Base URL logic to ensure consistency with ApiService
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  Future<String?> uploadFile(Uint8List fileBytes, String filename) async {
    const int maxFileSize = 10 * 1024 * 1024; // 10MB
    try {
      if (fileBytes.lengthInBytes > maxFileSize) {
        debugPrint(
            'File too large: ${(fileBytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)}MB');
        return 'SIZE_LIMIT_EXCEEDED';
      }

      final uri = Uri.parse('$_baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      );

      request.files.add(multipartFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);

        if (json['status'] == 'success' && json['file_path'] != null) {
          final filePath = json['file_path'];
          return '$_baseUrl/$filePath';
        }
        debugPrint('Backend error: $json');
        return null;
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Wrapper for ImagePicker XFile
  Future<String?> uploadImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return uploadFile(bytes, imageFile.name);
  }
}
