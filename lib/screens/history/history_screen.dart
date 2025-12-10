import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/responsive_scaffold.dart';

// --- Data Model (for demonstration) ---
class AnalysisRecord {
  final String imagePath;
  final String location;
  final String dateTime;
  final String riskLevel;
  final Color riskColor;

  AnalysisRecord({
    required this.imagePath,
    required this.location,
    required this.dateTime,
    required this.riskLevel,
    required this.riskColor,
  });
}

// --- Main Screen Widget ---
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // --- Mock Data ---
  static final Map<String, List<AnalysisRecord>> historyData = {
    'November 2023': [
      AnalysisRecord(
        imagePath: 'assets/images/mole1.png', // Placeholder path
        location: 'Left Forearm',
        dateTime: 'Nov 23, 10:15 AM',
        riskLevel: 'High Risk',
        riskColor: Colors.red.shade100,
      ),
    ],
    'October 2023': [
      AnalysisRecord(
        imagePath: 'assets/images/mole2.png', // Placeholder path
        location: 'Right Shoulder',
        dateTime: 'Oct 15, 03:30 PM',
        riskLevel: 'Monitor',
        riskColor: Colors.orange.shade100,
      ),
    ],
    'September 2023': [
      AnalysisRecord(
        imagePath: 'assets/images/mole3.png', // Placeholder path
        location: 'Upper Back',
        dateTime: 'Sep 02, 11:00 AM',
        riskLevel: 'Low Risk',
        riskColor: Colors.green.shade100,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      selectedIndex: 3,
      child: HistoryPage(),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: HistoryScreen.historyData.keys.length,
        itemBuilder: (context, index) {
          String month = HistoryScreen.historyData.keys.elementAt(index);
          List<AnalysisRecord> records = HistoryScreen.historyData[month]!;
          return _buildMonthSection(month, records);
        },
      ),
    );
  }

  Widget _buildMonthSection(String month, List<AnalysisRecord> records) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
            child: Text(
              month,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...records.map((record) => _buildHistoryCard(record)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AnalysisRecord record) {
    // We'll use a placeholder color since images aren't available yet.
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Placeholder color
                borderRadius: BorderRadius.circular(12),
                // TODO: Uncomment when images are added to assets
                // image: DecorationImage(
                //   image: AssetImage(record.imagePath),
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.location,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.dateTime,
                    style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.riskColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.riskLevel,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getRiskTextColor(record.riskColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _getRiskTextColor(Color backgroundColor) {
    if (backgroundColor == Colors.red.shade100) return Colors.red.shade900;
    if (backgroundColor == Colors.orange.shade100) return Colors.orange.shade900;
    return Colors.green.shade900;
  }
}
