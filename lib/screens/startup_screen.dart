import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.archive_outlined,
                color: Color(0xFF00AEEF),
                size: 32,
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1580820267682-426da823b514?q=80&w=2940&auto=format&fit=crop',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Intelligent Skin Health at Your Fingertips',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2939),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Get instant, AI-driven insights into your skin's health.",
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 16.0,
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    context.go('/register'), // Navigate to register
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    color: const Color(0xFF667085),
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Log In',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            context.go('/login'), // Navigate to login
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
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
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF00AEEF).withOpacity(0.1),
              radius: 24,
              child: Icon(icon, color: const Color(0xFF00AEEF)),
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
                      color: const Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF667085),
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
