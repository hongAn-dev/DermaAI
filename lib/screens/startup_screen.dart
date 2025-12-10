
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Lighter background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section with Icon
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF18A0FB).withOpacity(0.1),
                        const Color(0xFFE3F6FF).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_outlined, // More relevant icon
                    color: Color(0xFF18A0FB),
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),

                // Title and Subtitle
                Text(
                  'Intelligent Skin Health at Your Fingertips',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Get instant, AI-driven insights into your skin's health.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16.0,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 40),

                // Feature Cards
                _buildFeatureCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Analysis',
                  subtitle: 'Scan and analyze with our advanced AI.',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.article_outlined,
                  title: 'Personalized Insights',
                  subtitle: 'Receive tailored reports and recommendations.',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.trending_up,
                  title: 'Progress Tracking',
                  subtitle: "Monitor your skin's changes over time.",
                ),
                const SizedBox(height: 40),

                // Action Buttons
                ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18A0FB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF6C757D),
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF18A0FB),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF18A0FB).withOpacity(0.1),
              radius: 24,
              child: Icon(icon, color: const Color(0xFF18A0FB)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
