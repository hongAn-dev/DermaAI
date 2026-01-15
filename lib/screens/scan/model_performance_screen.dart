import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/utils/responsive.dart';

class ModelPerformanceScreen extends StatelessWidget {
  const ModelPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // For Training and Validation tabs
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Hiệu suất mô hình',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricsGrid(context),
              SizedBox(height: Responsive.scale(context, 24)),
              _buildInfoCard(
                context,
                title: 'Ma trận nhầm lẫn',
                  subtitle:
                      'Hiệu suất của mô hình phân loại trên tập dữ liệu kiểm thử.',
                // Placeholder image for the confusion matrix
                child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/confusion_matrix.png?alt=media&token=8d23d8f1-8f2c-4b7e-8b9a-4e2b0d71f6d3'),
              ),
              SizedBox(height: Responsive.scale(context, 24)),
                Text('Tiến trình huấn luyện',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 18))),
              SizedBox(height: Responsive.scale(context, 12)),
              TabBar(
                labelColor: const Color(0xFF18A0FB),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF18A0FB),
                tabs: const [
                  Tab(text: 'Huấn luyện'),
                  Tab(text: 'Xác thực'),
                ],
              ),
              SizedBox(height: Responsive.scale(context, 16)),
              _buildInfoCard(
                context,
                title: 'Độ chính xác theo epoch',
                subtitle: 'Sự cải thiện độ chính xác của mô hình trong quá trình huấn luyện.',
                // Placeholder image for the accuracy graph
                child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/accuracy_graph.png?alt=media&token=2d4778d4-2092-4217-8e6c-38f375f0a6d1'),
              ),
              SizedBox(height: Responsive.scale(context, 16)),
              _buildInfoCard(
                context,
                title: 'Mất mát theo epoch',
                subtitle: 'Sự giảm hàm mất mát trong quá trình huấn luyện.',
                // Placeholder image for the loss graph
                child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/loss_graph.png?alt=media&token=92e31573-fe84-4a4b-9d41-32a26569f195'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricCard(context, 'Độ chính xác tổng thể', '95.2%'),
        _buildMetricCard(context, 'Độ chính xác', '94.8%'),
        _buildMetricCard(context, 'Độ thu hồi', '96.1%'),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: colorWithOpacity(Colors.grey, 0.1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.scale(context, 12))),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Responsive.scale(context, 20.0),
              horizontal: Responsive.scale(context, 8.0)),
          child: Column(
            children: [
              Text(title,
                  style: GoogleFonts.manrope(color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              SizedBox(height: Responsive.scale(context, 8)),
              Text(value,
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 22)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title,
      required String subtitle,
      required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 16))),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16))),
                SizedBox(width: Responsive.scale(context, 8)),
                Icon(Icons.info_outline,
                    color: Colors.grey, size: Responsive.scale(context, 16)),
              ],
            ),
            SizedBox(height: Responsive.scale(context, 4)),
            Text(subtitle,
                style: GoogleFonts.manrope(
                    color: Colors.grey[600],
                    fontSize: Responsive.fontSize(context, 14))),
            SizedBox(height: Responsive.scale(context, 16)),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(Responsive.scale(context, 12)),
              child: child, // The placeholder image
            ),
          ],
        ),
      ),
    );
  }
}
