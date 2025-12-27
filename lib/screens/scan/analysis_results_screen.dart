import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/models/analysis_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'package:myapp/utils/responsive.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final AnalysisResponse analysisResult;
  final Uint8List imageBytes;

  const AnalysisResultsScreen({
    super.key,
    required this.analysisResult,
    required this.imageBytes,
  });

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();
  late Uint8List _heatmapBytes;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    widget.analysisResult.details
        .sort((a, b) => b.probability.compareTo(a.probability));
    _heatmapBytes = base64Decode(widget.analysisResult.heatmapImage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveAnalysis();
    });
  }

  Future<void> _saveAnalysis() async {
    const String logName = 'firestore.save';
    developer.log('Starting analysis save process...', name: logName);

    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      final analysisId = _uuid.v4();
      const String imageUrl = "";

      final topPrediction = widget.analysisResult.prediction;

      // This data structure is compatible with Firestore, which can handle Timestamps.
      final Map<String, dynamic> dataToSave = {
        'imagePath': imageUrl,
        'scanResult': {
          'prediction': {
            'className': topPrediction.className,
            'confidence': topPrediction.confidence,
            'confidenceScore':
                widget.analysisResult.details.first.probability / 100,
          },
          'status': 'success',
          'timestamp':
              Timestamp.now(), // Firestore handles this object type correctly.
          'userId': user.uid,
          'details':
              widget.analysisResult.details.map((e) => e.toJson()).toList(),
        },
      };

      // The actual call to save the data to Firestore.
      await _firestoreService.saveRawAnalysisResult(analysisId, dataToSave);

      developer.log('Successfully saved analysis with ID: $analysisId',
          name: logName);

      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e, s) {
      developer.log(
        'Failed to save analysis to history.',
        name: logName,
        level: 1000, // SEVERE
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Image _imageFromBytes(Uint8List bytes) {
    return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Analysis Results',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: Responsive.fontSize(context, 18)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.scale(context, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(context, widget.analysisResult.prediction),
            SizedBox(height: Responsive.scale(context, 24)),
            _buildImageComparisonCard(widget.imageBytes, _heatmapBytes),
            SizedBox(height: Responsive.scale(context, 24)),
            _buildBreakdownCard(widget.analysisResult.details),
            SizedBox(height: Responsive.scale(context, 24)),
            _buildDisclaimerBox(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Prediction prediction) {
    return Card(
      elevation: 4,
      shadowColor: colorWithOpacity(Colors.grey, 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 24.0)),
        child: Column(
          children: [
            Text(
              'Top Diagnosis',
              style: GoogleFonts.manrope(
                  fontSize: Responsive.fontSize(context, 16),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: Responsive.scale(context, 12)),
            Text(
              prediction.className,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: Responsive.fontSize(context, 26),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF18A0FB)),
            ),
            SizedBox(height: Responsive.scale(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confidence Level: ',
                  style: GoogleFonts.manrope(
                      fontSize: Responsive.fontSize(context, 16),
                      color: Colors.grey[800]),
                ),
                Text(
                  prediction.confidence,
                  style: GoogleFonts.manrope(
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageComparisonCard(
      Uint8List originalBytes, Uint8List heatmapBytes) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Original Image",
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 16))),
            Text("AI Focus Area",
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 16))),
          ],
        ),
        SizedBox(height: Responsive.scale(context, 12)),
        Row(
          children: [
            Expanded(child: _buildImageDisplayCard(originalBytes)),
            SizedBox(width: Responsive.scale(context, 16)),
            Expanded(child: _buildImageDisplayCard(heatmapBytes)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageDisplayCard(Uint8List imageBytes) {
    try {
      return AspectRatio(
        aspectRatio: 1 / 1,
        child: Card(
          elevation: 2,
          shadowColor: colorWithOpacity(Colors.grey, 0.1),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(Responsive.scale(context, 16))),
          clipBehavior: Clip.antiAlias,
          child: _imageFromBytes(imageBytes),
        ),
      );
    } catch (e) {
      return AspectRatio(
          aspectRatio: 1 / 1,
          child: Container(
            color: Colors.grey[200],
            child: Icon(Icons.broken_image,
                color: Colors.grey, size: Responsive.scale(context, 30)),
          ));
    }
  }

  Widget _buildBreakdownCard(List<DiseaseDetail> details) {
    return Card(
      elevation: 2,
      shadowColor: colorWithOpacity(Colors.grey, 0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 16))),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Analysis Breakdown',
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16),
                  color: Colors.black87),
            ),
            SizedBox(height: Responsive.scale(context, 16)),
            ...details.map((detail) => _buildProbabilityBar(detail)),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityBar(DiseaseDetail detail) {
    final isTopMatch =
        detail.probability == widget.analysisResult.details.first.probability;
    final color = isTopMatch ? const Color(0xFF18A0FB) : Colors.grey[400];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.scale(context, 8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  detail.disease,
                  style: GoogleFonts.manrope(
                      fontWeight:
                          isTopMatch ? FontWeight.bold : FontWeight.normal,
                      fontSize: Responsive.fontSize(context, 15)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(detail.probability).toStringAsFixed(2)}%',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 15),
                    color:
                        isTopMatch ? const Color(0xFF18A0FB) : Colors.black87),
              ),
            ],
          ),
          SizedBox(height: Responsive.scale(context, 8)),
          LinearPercentIndicator(
            lineHeight: Responsive.scale(context, 8.0),
            percent: detail.probability / 100,
            backgroundColor: Colors.grey[200],
            progressColor: color,
            barRadius: Radius.circular(Responsive.scale(context, 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 16)),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade800,
              size: Responsive.scale(context, 24)),
          SizedBox(width: Responsive.scale(context, 12)),
          Expanded(
            child: Text(
              'This AI tool is for informational purposes only and is not a substitute for professional medical advice. Always consult a qualified dermatologist.',
              style: GoogleFonts.manrope(
                  color: Colors.black87,
                  height: 1.4,
                  fontSize: Responsive.fontSize(context, 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (_isSaved)
          Card(
            color: Colors.green.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Saved to history'),
            ),
          ),
        SizedBox(height: Responsive.scale(context, 12)),
        ElevatedButton.icon(
          onPressed: () => context.go('/history'),
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text('View History'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF18A0FB),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, Responsive.scale(context, 55)),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Responsive.scale(context, 12))),
            textStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 16)),
          ),
        ),
        SizedBox(height: Responsive.scale(context, 12)),
        OutlinedButton.icon(
          onPressed: () => context.go('/scan'),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Scan Again'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF18A0FB),
            side: const BorderSide(color: Color(0xFF18A0FB)),
            minimumSize: Size(double.infinity, Responsive.scale(context, 50)),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Responsive.scale(context, 12))),
            textStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 16)),
          ),
        ),
      ],
    );
  }
}
