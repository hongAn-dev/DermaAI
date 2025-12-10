import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            'Model Performance',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricsGrid(),
              const SizedBox(height: 24),
              _buildInfoCard(
                title: 'Confusion Matrix',
                subtitle: 'Performance of the classification model on the test dataset.',
                // Placeholder image for the confusion matrix
                child: Image.network('https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/confusion_matrix.png?alt=media&token=8d23d8f1-8f2c-4b7e-8b9a-4e2b0d71f6d3'),
              ),
              const SizedBox(height: 24),
              Text('Training Progress', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TabBar(
                labelColor: const Color(0xFF18A0FB),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF18A0FB),
                tabs: const [
                  Tab(text: 'Training'),
                  Tab(text: 'Validation'),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Accuracy Over Epochs',
                subtitle: 'Model accuracy improvement during training.',
                 // Placeholder image for the accuracy graph
                child: Image.network('https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/accuracy_graph.png?alt=media&token=2d4778d4-2092-4217-8e6c-38f375f0a6d1'),
              ),
              const SizedBox(height: 16),
               _buildInfoCard(
                title: 'Loss Over Epochs',
                subtitle: 'Model loss reduction during training.',
                // Placeholder image for the loss graph
                child: Image.network('https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/loss_graph.png?alt=media&token=92e31573-fe84-4a4b-9d41-32a26569f195'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricCard('Overall Accuracy', '95.2%'),
        _buildMetricCard('Precision', '94.8%'),
        _buildMetricCard('Recall', '96.1%'),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(title, style: GoogleFonts.manrope(color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.info_outline, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.manrope(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child, // The placeholder image
            ),
          ],
        ),
      ),
    );
  }
}
