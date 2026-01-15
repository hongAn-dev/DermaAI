import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  late AnimationController _controller;
  late AnimationController _scanningController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanningController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanningController.dispose();
    super.dispose();
  }

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
        SnackBar(content: Text('Lấy ảnh thất bại: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh trước!')),
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
        final shouldReset = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(
              analysisResult: result,
              imageBytes: bytesForAnalysis,
            ),
          ),
        );

        if (shouldReset == true && mounted) {
          setState(() {
            _image = null;
            _imageBytes = null;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Phân tích thất bại. Không có kết quả trả về.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi phân tích ảnh: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          // _image = null; // Optional: Keep image to allow re-try
          // _imageBytes = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Phân tích da AI',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, 18),
              color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;
          final content = _imageBytes == null
              ? _buildScannerInterface()
              : _buildAnalysisInterface();

          if (isWeb) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Center(child: content),
                    ),
                    Container(
                      width: 1,
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.scale(context, 32)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hướng dẫn chụp',
                              style: GoogleFonts.manrope(
                                fontSize: Responsive.fontSize(context, 24),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInstructionStep(context, '1',
                                'Đảm bảo đủ ánh sáng', Icons.light_mode),
                            const SizedBox(height: 16),
                            _buildInstructionStep(context, '2',
                                'Giữ camera ổn định', Icons.camera),
                            const SizedBox(height: 16),
                            _buildInstructionStep(
                                context,
                                '3',
                                'Vùng da nằm gọn trong khung',
                                Icons.center_focus_weak),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.privacy_tip_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Ảnh của bạn được mã hóa và chỉ sử dụng cho mục đích phân tích.',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: content);
          }
        },
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String step, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildScannerInterface() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.scale(context, 24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bắt đầu kiểm tra',
            style: GoogleFonts.manrope(
              fontSize: Responsive.fontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: Responsive.scale(context, 8)),
          Text(
            'Đặt vùng da cần kiểm tra vào khung hình bên dưới',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: Responsive.fontSize(context, 14),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: Responsive.scale(context, 40)),

          // --- Pulsing Scan Zone ---
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: SizedBox(
              width: Responsive.scale(context, 300),
              height: Responsive.scale(context, 300),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base pulsing circle
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: Responsive.scale(context, 250),
                        height: Responsive.scale(context, 250),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor
                                .withOpacity(0.5 + (_controller.value * 0.5)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor
                                  .withOpacity(0.2 * _controller.value),
                              blurRadius: 20 + (10 * _controller.value),
                              spreadRadius: 5 * _controller.value,
                            )
                          ],
                        ),
                        // Add ClipOval to ensure children (laser) stay inside
                        child: ClipOval(
                          child: Stack(
                            children: [
                              // Scanning Line
                              AnimatedBuilder(
                                animation: _scanningController,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _scanningController.value *
                                        Responsive.scale(context, 250),
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                primaryColor.withOpacity(0.8),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ],
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Camera Icon and Text (Outside ClipOval so it's not clipped if we want effects)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.center_focus_strong,
                          size: Responsive.scale(context, 60),
                          color: primaryColor),
                      SizedBox(height: Responsive.scale(context, 12)),
                      Text('CHẠM ĐỂ CHỤP',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: Responsive.scale(context, 40)),

          // --- Alternative Button ---
          // --- Alternative Button ---
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Hoặc chọn từ thư viện'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
              textStyle: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInterface() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.scale(context, 24)),
      child: Column(
        children: [
          Container(
            height: Responsive.scale(context, 300),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: MemoryImage(_imageBytes!),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10)
              ],
            ),
          ),
          SizedBox(height: Responsive.scale(context, 32)),
          if (_isAnalyzing)
            Column(
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Đang phân tích tế bào da...',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Quá trình này mất khoảng vài giây',
                  style: GoogleFonts.manrope(color: Colors.grey),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeImage,
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('BẮT ĐẦU PHÂN TÍCH'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      // Theme data handles the rest
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _image = null;
                      _imageBytes = null;
                    });
                  },
                  child: const Text('Chọn ảnh khác'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
