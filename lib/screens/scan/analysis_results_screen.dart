import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/analysis_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();
  late Uint8List _heatmapBytes;
  bool _isSaved = false;
  int _selectedTabIndex = 0; // 0 = Original, 1 = Heatmap

  @override
  void initState() {
    super.initState();
    // Using int state instead of TabController
    widget.analysisResult.details
        .sort((a, b) => b.probability.compareTo(a.probability));
    _heatmapBytes = base64Decode(widget.analysisResult.heatmapImage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveAnalysis();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveAnalysis() async {
    const String logName = 'firestore.save';
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final analysisId = _uuid.v4();
      final topPrediction = widget.analysisResult.prediction;

      final Map<String, dynamic> dataToSave = {
        'imagePath':
            "", // Placeholder for explicit image URL if uploaded to Storage
        'scanResult': {
          'prediction': {
            'className': topPrediction.className,
            'confidence': topPrediction.confidence,
            'confidenceScore':
                widget.analysisResult.details.first.probability / 100,
          },
          'status': 'success',
          'timestamp': Timestamp.now(),
          'userId': user.uid,
          'details':
              widget.analysisResult.details.map((e) => e.toJson()).toList(),
        },
      };

      await _firestoreService.saveRawAnalysisResult(analysisId, dataToSave);

      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      developer.log('Failed to save analysis', error: e, name: logName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Kết quả phân tích',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;

          if (isWeb) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.scale(context, 20.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Image Viewer
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildImageViewer(context),
                              SizedBox(height: Responsive.scale(context, 24)),
                              _buildHealthTip(context), // Added static content
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.scale(context, 32)),
                      // Right Column: Results & Actions
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildScoreCard(context),
                              SizedBox(height: Responsive.scale(context, 24)),
                              _buildDetailsCard(context),
                              SizedBox(height: Responsive.scale(context, 24)),
                              _buildActionButtons(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.scale(context, 20.0)),
              child: Column(
                children: [
                  _buildScoreCard(context),
                  SizedBox(height: Responsive.scale(context, 24)),
                  _buildImageViewer(context),
                  SizedBox(height: Responsive.scale(context, 24)),
                  _buildDetailsCard(context),
                  SizedBox(height: Responsive.scale(context, 24)),
                  _buildActionButtons(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    final topDetail = widget.analysisResult.details.first;
    final confidencePercent = topDetail.probability / 100;

    // Determine color based on severity (heuristic: malignant/carcinoma = red)
    final isDanger = topDetail.disease.toLowerCase().contains('malignant') ||
        topDetail.disease.toLowerCase().contains('carcinoma') ||
        topDetail.disease.toLowerCase().contains('melanoma');
    final color = isDanger ? Colors.redAccent : Colors.green;

    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kết quả chẩn đoán',
                      style: GoogleFonts.manrope(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      topDetail.disease,
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDanger ? 'Cần chú ý cao' : 'Rủi ro thấp',
                        style: GoogleFonts.manrope(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: confidencePercent,
                center: Text(
                  "${(confidencePercent * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                progressColor: color,
                backgroundColor: color.withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return Column(
      children: [
        // Custom Toggle
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildToggleItem("Ảnh gốc", 0),
              _buildToggleItem("Heatmap AI", 1),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedTabIndex == 0
                ? _buildImageContainer(widget.imageBytes,
                    key: const ValueKey('original'))
                : _buildImageContainer(_heatmapBytes,
                    key: const ValueKey('heatmap')),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTip(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FD), // Light blue tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF18A0FB).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline,
                color: Color(0xFF18A0FB), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo sức khỏe',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF18A0FB),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kiểm tra da thường xuyên giúp phát hiện sớm các dấu hiệu bất thường. Nếu nốt ruồi thay đổi kích thước hoặc màu sắc, hãy tham khảo ý kiến bác sĩ ngay.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(Uint8List bytes, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        image: DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Theme.of(context).cardTheme.shadowColor != null
            ? [
                BoxShadow(
                    color: Theme.of(context).cardTheme.shadowColor!,
                    blurRadius: 10)
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích chi tiết',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
          ...widget.analysisResult.details.take(3).map((detail) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(detail.disease,
                          style:
                              GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                      Text('${detail.probability.toStringAsFixed(1)}%',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: detail.probability / 100,
                    backgroundColor: Colors.grey[100],
                    progressColor: Theme.of(context).colorScheme.primary,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                    animation: true,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (_isSaved)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Đã lưu vào lịch sử',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton(
          onPressed: () => context.go('/history'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: const Color(0xFF18A0FB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Xem Lịch Sử',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Quét ảnh khác',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
