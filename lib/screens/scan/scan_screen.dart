
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/screens/responsive_scaffold.dart';

// Updated data class to use image bytes for web compatibility
class AnalysisScreenNavData {
  final AnalysisResponse analysisResult;
  final Uint8List imageBytes; // Changed from File to Uint8List

  AnalysisScreenNavData({required this.analysisResult, required this.imageBytes});
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? imageXFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (imageXFile == null || !mounted) return;

    // Read image data into a Uint8List for cross-platform compatibility
    final imageBytes = await imageXFile.readAsBytes();

    setState(() { _isLoading = true; });

    try {
      final analysisResult = await _apiService.analyzeImage(imageXFile);
      
      if (!mounted) return;
      setState(() { _isLoading = false; });

      if (analysisResult != null) {
        // Use the updated nav data with imageBytes
        final navData = AnalysisScreenNavData(
          analysisResult: analysisResult,
          imageBytes: imageBytes,
        );
        context.go('/analysis_results', extra: navData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze image. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      selectedIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'New Analysis',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Analyze Your Skin',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload a clear, well-lit photo of the skin area\nfor an AI-powered analysis.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    _buildOptionCard(
                      icon: Icons.camera_alt_outlined,
                      text: 'Take a photo',
                      onTap: () => _pickAndAnalyze(ImageSource.camera),
                    ),
                    const SizedBox(height: 24),
                    _buildOptionCard(
                      icon: Icons.photo_library_outlined,
                      text: 'Upload from Gallery',
                      onTap: () => _pickAndAnalyze(ImageSource.gallery),
                    ),
                     const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'This AI analysis is not a substitute for professional\nmedical advice. Always consult a healthcare provider.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      const SizedBox(height: 20),
                      Text(
                        'Analyzing... Please wait.',
                        style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
         opacity: _isLoading ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF18A0FB)),
              const SizedBox(height: 16),
              Text(
                text,
                style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
