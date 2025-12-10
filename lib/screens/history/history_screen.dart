
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/analysis_model.dart';
import 'package:myapp/services/realtime_database_service.dart'; // Updated import
import 'package:myapp/screens/responsive_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RealtimeDatabaseService _rtdbService = RealtimeDatabaseService(); // Updated service

  Map<String, List<AnalysisResult>> _groupAnalysesByMonth(
      List<AnalysisResult> analyses) {
    final Map<String, List<AnalysisResult>> grouped = {};
    for (var analysis in analyses) {
      final monthYear = DateFormat('MMMM yyyy').format(analysis.timestamp);
      if (grouped[monthYear] == null) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(analysis);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      selectedIndex: 3,
      child: Scaffold(
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
            IconButton(
                icon: const Icon(Icons.search, color: Colors.black), 
                onPressed: () { /* TODO: Implement search functionality */ }
            ),
            IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () { /* TODO: Implement filter/sort options */ }
            ),
          ],
        ),
        body: StreamBuilder<List<AnalysisResult>>(
          stream: _rtdbService.getAnalysisHistory(), // Updated stream source
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final analyses = snapshot.data!;
            // Sort by timestamp descending before grouping
            analyses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            final groupedData = _groupAnalysesByMonth(analyses);
            final months = groupedData.keys.toList();

            return ListView.builder(
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final records = groupedData[month]!;
                return _buildMonthSection(month, records);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No History Yet',
            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Your scan results will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600]),
          ),
           const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.go('/scan'),
              icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
              label: const Text('Start First Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18A0FB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<AnalysisResult> records) {
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
          ...records.map((record) => _buildHistoryCard(context, record)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AnalysisResult record) {
    final risk = _getRiskProfile(record.probability);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          // Placeholder for future detail screen navigation
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildThumbnail(record.imageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.disease,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                       overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(record.timestamp),
                      style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: risk.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        risk.level,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: risk.textColor,
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
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
          );
        },
      ),
    );
  }

  ({String level, Color backgroundColor, Color textColor}) _getRiskProfile(double probability) {
    if (probability > 75) {
      return (
        level: 'High Risk',
        backgroundColor: Colors.red.shade100,
        textColor: Colors.red.shade900
      );
    }
    if (probability > 40) {
      return (
        level: 'Monitor',
        backgroundColor: Colors.orange.shade100,
        textColor: Colors.orange.shade900
      );
    }
    return (
      level: 'Low Risk',
      backgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade900
    );
  }
}
