import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';

class AnalysisResultsScreen extends StatefulWidget {
  const AnalysisResultsScreen({super.key});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  bool _isOverviewExpanded = true;
  bool _isStepsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Analysis Results',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildHeatmapCard(),
            const SizedBox(height: 24),
            _buildExpandableCard(
              title: 'Overview',
              isExpanded: _isOverviewExpanded,
              onTap: () => setState(() => _isOverviewExpanded = !_isOverviewExpanded),
              child: Text(
                'Psoriasis is a chronic skin condition that causes cells to build up rapidly on the surface of the skin. The extra skin cells form scales and red patches that are sometimes itchy and painful.',
                style: GoogleFonts.manrope(color: Colors.grey[700], height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            _buildExpandableCard(
              title: 'Recommended Next Steps',
              isExpanded: _isStepsExpanded,
              onTap: () => setState(() => _isStepsExpanded = !_isStepsExpanded),
              child: Text(
                '1. Consult a board-certified dermatologist.\n2. Follow the prescribed treatment plan.\n3. Monitor your skin for any changes.',
                 style: GoogleFonts.manrope(color: Colors.grey[700], height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            _buildDisclaimerBox(),
            const SizedBox(height: 24),
            _buildActionButtons(context), // Pass context
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Results Summary', style: GoogleFonts.manrope(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Match:\nPsoriasis', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('85%\nMatch', textAlign: TextAlign.center, style: GoogleFonts.manrope(color: Colors.blue.shade800, fontWeight: FontWeight.bold, height: 1.2)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSummaryItem('Potential Severity', 'Moderate', Colors.orange)),
                Expanded(child: _buildSummaryItem('Recommendation', 'Consult Specialist', Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.manrope(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor)),
      ],
    );
  }

  Widget _buildHeatmapCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GRAD-Heatmap Visualization', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Placeholder for the actual image
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/project-id-dev-b2d9b.appspot.com/o/frau.jpg?alt=media&token=1f7902e8-5b42-411a-821a-e7616f735623'), // Using a network placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.red.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                ),
              ),
              Positioned(
                bottom: 40,
                left: 16,
                child: Chip(
                  avatar: const Icon(Icons.flare_outlined, color: Colors.white, size: 16),
                  label: const Text('Areas of Interest'),
                  backgroundColor: Colors.black.withOpacity(0.5),
                  labelStyle: GoogleFonts.manrope(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.yellow, Colors.red],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Low Interest', style: GoogleFonts.manrope(color: Colors.grey[600])),
                        Text('High Interest', style: GoogleFonts.manrope(color: Colors.grey[600])),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableCard({required String title, required Widget child, required bool isExpanded, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
              if (isExpanded) const SizedBox(height: 16),
              if (isExpanded) child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This AI analysis is for informational purposes only and is not a medical diagnosis. Please consult a qualified healthcare professional for medical advice.',
              style: GoogleFonts.manrope(color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) { // Accept context
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/consult'), // Navigate to consult screen
          icon: const Icon(Icons.person_search_outlined),
          label: const Text('Find a Specialist'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF18A0FB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/model_performance'), // Navigate to model performance screen
          icon: const Icon(Icons.bar_chart_outlined),
          label: const Text('Xem hiệu suất mô hình'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF18A0FB),
            side: const BorderSide(color: Color(0xFF18A0FB)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
