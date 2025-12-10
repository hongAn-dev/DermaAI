
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            Text('Last Updated: May 24, 2024', style: GoogleFonts.manrope(color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'This policy describes how we collect, use, and protect your personal information when you use our AI dermatological diagnosis application.'
            ),
            _buildSection(
              '1. Information Collection',
              'We collect information you provide directly to us, such as when you create an account, upload images for analysis, or contact us for support. This information may include your name, email address, and dermatological images.'
            ),
            _buildSection(
              '2. Use of Information',
              'Your information is used to provide and improve our services, train our AI models, and communicate with you about important updates. We are committed to anonymizing image data used for research purposes.'
            ),
            _buildSection(
              '3. Data Sharing and Disclosure',
              'We do not sell your personal information. Data may be shared with research partners or third-party service providers under strict confidentiality agreements.'
            ),
            _buildSection(
              '4. Data Security',
              'We implement technical and organizational security measures to protect your data from unauthorized access, alteration, or destruction.'
            ),
            _buildSection(
              '5. User Rights',
              'You have the right to access, modify, or delete your personal information. You can exercise these rights through your account settings or by contacting us.'
            ),
            _buildSection(
              '6. Contact Us',
              'If you have any questions about this privacy policy, please contact us via email: privacy@skinai.app.'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.manrope(fontSize: 15, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
