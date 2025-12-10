
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/responsive_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Jane';

    // Dummy data for recent analyses
    final List<Map<String, dynamic>> recentAnalysesData = [
      {
        'status': 'Low Risk',
        'statusColor': Colors.green,
        'date': 'Sep 20, 2023',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/skindiseasedetection-623ae.appspot.com/o/resources%2Fnevus_example.jpg?alt=media&token=40463390-3606-4767-91d4-850935535569',
      },
      {
        'status': 'Monitor',
        'statusColor': Colors.orange,
        'date': 'Sep 18, 2023',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/skindiseasedetection-623ae.appspot.com/o/resources%2Fmelanoma_example.jpg?alt=media&token=9d39294e-da89-4113-a75d-639db5481e18',
      },
    ];

    return ResponsiveScaffold(
      selectedIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                _buildHeader(displayName),
                const SizedBox(height: 32),

                // --- Responsive Layout for Cards ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 768;
                    if (isWideScreen) {
                      // --- Web Layout ---
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildAnalysisCard(context)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildConsultCard(context)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildRecentAnalysesSection(context, recentAnalysesData, isWideScreen: true),
                        ],
                      );
                    } else {
                      // --- Mobile Layout ---
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAnalysisCard(context),
                          const SizedBox(height: 32),
                          _buildRecentAnalysesSection(context, recentAnalysesData, isWideScreen: false),
                          const SizedBox(height: 32),
                          _buildConsultCard(context),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $displayName 👋',
          style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's check your skin today. Early detection saves lives.",
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(BuildContext context) {
    return Card(
      color: const Color(0xFFE3F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF18A0FB),
              child: Icon(Icons.search, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Start New Skin Analysis',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Get an AI-powered skin check in seconds. Upload a photo to get started.',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const Spacer(), // This is now safe to use
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18A0FB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Analyze New Spot', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnalysesSection(BuildContext context, List<Map<String, dynamic>> data, {required bool isWideScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Recent Analyses',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        isWideScreen
            ? Row(
                children: data.map((item) => Expanded(child: _buildRecentAnalysisItem(item))).toList().expand((widget) => [widget, const SizedBox(width: 20)]).toList()..removeLast(),
              )
            : Column(
                children: data.map((item) => _buildRecentAnalysisItem(item)).toList().expand((widget) => [widget, const SizedBox(height: 16)]).toList()..removeLast(),
              ),
      ],
    );
  }

  Widget _buildRecentAnalysisItem(Map<String, dynamic> data) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(data['imageUrl']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: data['statusColor'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(data['status'], style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(data['date'], style: GoogleFonts.manrope(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultCard(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const CircleAvatar(
              backgroundColor: Colors.black87,
              child: Icon(Icons.person_search_outlined, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('Consult a Dermatologist', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Want a professional opinion? Find a certified dermatologist near you.', style: GoogleFonts.manrope(height: 1.5)),
            const Spacer(), // This is now safe to use
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/consult'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
               child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Find a Specialist', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
