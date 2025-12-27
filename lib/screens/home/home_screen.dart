import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import 'package:myapp/utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final String displayName = user?.displayName ?? 'Jane';

    return ResponsiveScaffold(
      selectedIndex: 0,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.scale(context, 24.0)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                _buildHeader(displayName),
                SizedBox(height: Responsive.scale(context, 32)),

                // --- Recent History Section ---
                _buildRecentHistory(context),
                SizedBox(height: Responsive.scale(context, 32)),

                // --- Responsive Layout for Cards ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 768;
                    if (isWideScreen) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildAnalysisCard(context)),
                                SizedBox(width: Responsive.scale(context, 24)),
                                Expanded(child: _buildConsultCard(context)),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAnalysisCard(context),
                          SizedBox(height: Responsive.scale(context, 24)),
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
          style: GoogleFonts.manrope(
              fontSize: Responsive.fontSize(context, 32),
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: Responsive.scale(context, 8)),
        Text(
          "Let's check your skin today. Early detection saves lives.",
          style: GoogleFonts.manrope(
              fontSize: Responsive.fontSize(context, 16),
              color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scan_history')
          .where('scanResult.userId', isEqualTo: user!.uid)
          // NOTE: The orderBy clause is added back, assuming the index is now enabled.
          // If errors persist, this is the first place to check.
          .orderBy('scanResult.timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // If there is no history, don't show anything on the home screen.
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.manrope(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: Text('View All',
                      style: GoogleFonts.manrope(
                          color: const Color(0xFF18A0FB),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return _buildHistoryTile(docs[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scanResultData = data['scanResult'] as Map<String, dynamic>?;
    final predictionData =
        scanResultData?['prediction'] as Map<String, dynamic>?;
    final predictionText = predictionData?['className'] as String? ?? 'N/A';
    final timestamp = (scanResultData?['timestamp'] as Timestamp?)?.toDate();
    final statusColor = predictionText.toLowerCase().contains('malignant')
        ? Colors.red.shade400
        : Colors.green.shade400;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16),
          vertical: Responsive.scale(context, 12)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorWithOpacity(Colors.grey, 0.08),
              spreadRadius: 1,
              blurRadius: 10,
            )
          ]),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  predictionText,
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 16)),
                ),
                SizedBox(height: Responsive.scale(context, 4)),
                Text(
                  timestamp != null
                      ? DateFormat.yMMMd().add_jm().format(timestamp)
                      : 'No date',
                  style: GoogleFonts.manrope(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 13)),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.scale(context, 16)),
          Icon(Icons.circle,
              color: statusColor, size: Responsive.scale(context, 14)),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context) {
    return Card(
      color: const Color(0xFFE3F6FF),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20))),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF18A0FB),
                  radius: Responsive.avatarRadius(context, base: 24),
                  child: Icon(Icons.search,
                      color: Colors.white, size: Responsive.scale(context, 20)),
                ),
                SizedBox(height: Responsive.scale(context, 16)),
                Text(
                  'Start New Skin Analysis',
                  style: GoogleFonts.manrope(
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: Responsive.scale(context, 8)),
                Text(
                  'Get an AI-powered skin check in seconds. Upload a photo to get started.',
                  style: GoogleFonts.manrope(
                      fontSize: Responsive.fontSize(context, 14),
                      color: Colors.black54,
                      height: 1.5),
                ),
              ],
            ),
            SizedBox(height: Responsive.scale(context, 24)),
            ElevatedButton(
              onPressed: () => context.go('/scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18A0FB),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Responsive.scale(context, 10))),
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scale(context, 24),
                    vertical: Responsive.scale(context, 12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Analyze New Spot',
                      style: GoogleFonts.manrope(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: Responsive.scale(context, 8)),
                  Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: Responsive.scale(context, 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultCard(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20))),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black87,
                  radius: Responsive.avatarRadius(context, base: 24),
                  child: Icon(Icons.person_search_outlined,
                      color: Colors.white, size: Responsive.scale(context, 20)),
                ),
                SizedBox(height: Responsive.scale(context, 16)),
                Text('Consult a Dermatologist',
                    style: GoogleFonts.manrope(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold)),
                SizedBox(height: Responsive.scale(context, 8)),
                Text(
                    'Want a professional opinion? Find a certified dermatologist near you.',
                    style: GoogleFonts.manrope(
                        height: 1.5,
                        fontSize: Responsive.fontSize(context, 14))),
              ],
            ),
            SizedBox(height: Responsive.scale(context, 24)),
            ElevatedButton(
              onPressed: () => context.go('/consult'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Responsive.scale(context, 10))),
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scale(context, 24),
                    vertical: Responsive.scale(context, 12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Find a Specialist',
                      style: GoogleFonts.manrope(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
