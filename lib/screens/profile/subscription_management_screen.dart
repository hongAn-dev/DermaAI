
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

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
          'Subscription Management',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentPlanCard(),
            const SizedBox(height: 32),
            _buildSectionTitle('Your Plan Benefits'),
            _buildBenefitItem(Icons.all_inclusive, 'Unlimited AI Scans'),
            _buildBenefitItem(Icons.health_and_safety_outlined, 'Monthly Expert Consultation'),
            _buildBenefitItem(Icons.history_toggle_off, 'Scan History Storage'),
            _buildBenefitItem(Icons.support_agent, 'Priority Support'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18A0FB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('Upgrade Plan'),
            ),
            const SizedBox(height: 24),
            Center(child: TextButton(onPressed: () {}, child: Text('Manage Payment Methods', style: GoogleFonts.manrope(color: Colors.grey[700], fontWeight: FontWeight.w500)))),
            Center(child: TextButton(onPressed: () {}, child: Text('Transaction History', style: GoogleFonts.manrope(color: Colors.grey[700], fontWeight: FontWeight.w500)))),
            Center(child: TextButton(onPressed: () {}, child: Text('Cancel Subscription', style: GoogleFonts.manrope(color: Colors.red, fontWeight: FontWeight.w500)))),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium Plan', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Renews on Dec 25, 2024', style: GoogleFonts.manrope(color: Colors.grey[600])),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Active', style: GoogleFonts.manrope(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF18A0FB).withOpacity(0.1),
          foregroundColor: const Color(0xFF18A0FB),
          child: Icon(icon, size: 20),
        ),
        title: Text(text, style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }
}
