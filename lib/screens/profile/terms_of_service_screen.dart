
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Updated: October 23, 2023', style: GoogleFonts.manrope(color: Colors.grey[600])),
            const SizedBox(height: 16),
            _buildExpansionTile('Introduction', 'This document serves as a binding agreement...'),
            _buildExpansionTile('Privacy', 'Our Privacy Policy, which is available on our website, explains how we collect, use, and protect your personal information...'),
            _buildExpansionTile('User Responsibilities', 'You agree to use this application only for lawful purposes and in a way that does not infringe the rights of, restrict, or inhibit anyone else\'s use and enjoyment of the application...'),
            _buildExpansionTile(
              'Scope of Services & AI Limitations',
              'Our AI technology is designed to provide suggestions based on the images you provide. However, it is not a definitive medical diagnosis and may not be 100% accurate. Always seek advice from a qualified medical professional.',
              initiallyExpanded: true,
            ),
             _buildExpansionTile('Intellectual Property', 'All content and software associated with this application are the property of DermAI Inc. or its licensors...'),
            _buildExpansionTile('Disclaimer of Warranties', 'The service is provided "as is" without any warranties of any kind, either express or implied...'),
            _buildExpansionTile('Limitation of Liability', 'DermAI Inc. shall not be liable for any indirect, incidental, special, consequential or punitive damages...'),
            _buildExpansionTile('Contact Information', 'If you have any questions about these Terms, please contact us at contact@dermai.app.'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content, {bool initiallyExpanded = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: GoogleFonts.manrope(color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
