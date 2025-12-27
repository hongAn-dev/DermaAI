import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/analysis_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/screens/scan/analysis_results_screen.dart';
import 'package:myapp/utils/responsive.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (!mounted || image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _image = image;
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    final Uint8List bytesForAnalysis = _imageBytes!;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final AnalysisResponse? result = await _apiService.analyzeImage(_image!);
      if (!mounted) return;

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(
              analysisResult: result,
              imageBytes: bytesForAnalysis,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Analysis failed. No result was returned.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error in analyzeImage: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _image = null;
          _imageBytes = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'New Analysis',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: Responsive.fontSize(context, 18)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: _imageBytes == null
          ? _buildSelectionScreen()
          : _buildAnalysisScreen(),
    );
  }

  Widget _buildSelectionScreen() {
    // FIX: Wrapped the content in a SingleChildScrollView to prevent overflow on smaller screens.
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: Responsive.scale(context, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.scale(context, 20)),
            Text(
              'Analyze Your Skin',
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 28),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212529),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 8)),
            Text(
              'Upload a clear, well-lit photo of the skin area for an AI-powered analysis.',
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 16),
                color: const Color(0xFF6C757D),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 40)),
            _buildOptionCard(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(height: Responsive.scale(context, 20)),
            _buildOptionCard(
              icon: Icons.photo_library_outlined,
              label: 'Upload from Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            SizedBox(
                height: Responsive.scale(
                    context, 60)), // Replaced Spacer with a flexible SizedBox
            Padding(
              padding: EdgeInsets.only(bottom: Responsive.scale(context, 24.0)),
              child: Text(
                'This AI analysis is not a substitute for professional medical advice. Always consult a healthcare provider.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: Responsive.fontSize(context, 12),
                  color: const Color(0xFF6C757D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    const Color iconColor = Color(0xFF18A0FB);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: Responsive.scale(context, 32)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
          boxShadow: [
            BoxShadow(
                color: colorWithOpacity(Colors.grey, 0.1),
                spreadRadius: 1,
                blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: Responsive.scale(context, 48), color: iconColor),
            SizedBox(height: Responsive.scale(context, 16)),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212529),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.scale(context, 24.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Your Photo',
            style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212529)),
          ),
          SizedBox(height: Responsive.scale(context, 20)),
          if (_imageBytes != null)
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(Responsive.scale(context, 16.0)),
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: Responsive.scale(context, 30)),
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                onPressed: _analyzeImage,
                label: const Text('Analyze Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18A0FB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: Responsive.scale(context, 16)),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Responsive.scale(context, 12))),
                  textStyle: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          SizedBox(height: Responsive.scale(context, 10)),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _image = null;
                _imageBytes = null;
              }),
              label: const Text('Choose a different photo'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
