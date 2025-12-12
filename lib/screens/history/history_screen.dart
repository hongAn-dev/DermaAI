import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import 'dart:developer' as developer;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  Map<String, List<QueryDocumentSnapshot>> _groupAnalysesByMonth(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    // Sort documents locally since we removed the orderBy from the query
    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      final aTimestamp = (aData?['scanResult']?['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final bTimestamp = (bData?['scanResult']?['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      return bTimestamp.compareTo(aTimestamp); // Descending order
    });

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final scanResult = data['scanResult'] as Map<String, dynamic>?;
      final timestamp = (scanResult?['timestamp'] as Timestamp?)?.toDate();

      if (timestamp != null) {
        final monthYear = DateFormat('MMMM yyyy').format(timestamp);
        if (grouped[monthYear] == null) {
          grouped[monthYear] = [];
        }
        grouped[monthYear]!.add(doc);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      developer.log("DEBUG: Current User ID in History Screen: ${user.uid}", name: 'history.screen');
    } else {
      developer.log("DEBUG: User is not logged in.", name: 'history.screen');
    }

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
        ),
        body: user == null
            ? const Center(child: Text('Please log in to see your history.'))
            : StreamBuilder<QuerySnapshot>(
                // DIAGNOSTIC TEST: Temporarily removed .orderBy to isolate the index issue.
                stream: FirebaseFirestore.instance
                    .collection('scan_history')
                    .where('scanResult.userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    developer.log("Firestore Stream Error", name: 'history.screen', error: snapshot.error, stackTrace: snapshot.stackTrace);
                    return Center(child: Text("An error occurred: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                     developer.log("Stream has no data or is empty.", name: 'history.screen');
                    return _buildEmptyState();
                  }

                  final docs = snapshot.data!.docs;
                  final groupedData = _groupAnalysesByMonth(docs);
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

  Widget _buildMonthSection(String month, List<QueryDocumentSnapshot> records) {
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
          ...records.map((record) => _buildHistoryCard(context, record)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final scanResultData = data['scanResult'] as Map<String, dynamic>?;
    final predictionData = scanResultData?['prediction'] as Map<String, dynamic>?;
    final predictionText = predictionData?['className'] as String? ?? 'Analysis result not available.';
    final confidenceScore = predictionData?['confidenceScore'] as num? ?? 0.0;

    final timestamp = (scanResultData?['timestamp'] as Timestamp?)?.toDate();

    final statusColor = predictionText.toLowerCase().contains('malignant') 
      ? Colors.red.shade700 
      : Colors.green.shade700;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.circle, color: statusColor, size: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predictionText,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(confidenceScore * 100).toStringAsFixed(1)}%',
                     style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              timestamp != null ? DateFormat('MMM dd').format(timestamp) : '',
              style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
