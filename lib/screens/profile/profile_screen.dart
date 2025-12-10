
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // A map to associate routes with their titles and icons
    final settingsItems = {
      'ACCOUNT': [
        {'icon': Icons.person_outline, 'title': 'Personal Information', 'route': '/profile/personal_information'},
        {'icon': Icons.subscriptions_outlined, 'title': 'Subscription Management', 'route': '/profile/subscription'},
      ],
      'PREFERENCES': [
        {'icon': Icons.palette_outlined, 'title': 'Appearance', 'route': '/profile/appearance'},
      ],
      'SECURITY & PRIVACY': [
        {'icon': Icons.lock_outline, 'title': 'Change Password', 'route': '/profile/change_password'},
        {'icon': Icons.shield_outlined, 'title': 'Privacy Policy', 'route': '/profile/privacy_policy'},
        {'icon': Icons.article_outlined, 'title': 'Terms of Service', 'route': '/profile/terms_of_service'},
      ],
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user, context),
                const SizedBox(height: 24),
                ...settingsItems.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(entry.key),
                      _buildSettingsCard(
                        entry.value.map((item) {
                          return _buildSettingsItem(
                            item['icon'] as IconData,
                            item['title'] as String,
                            () => context.go(item['route'] as String),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 8),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Eleanor Vance',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'eleanor.vance@example.com',
                style: GoogleFonts.manrope(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            backgroundColor: const Color(0xFF18A0FB),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 16),
              onPressed: () => context.go('/profile/personal_information'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF18A0FB)),
      title: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          context.go('/login');
        },
        child: Text(
          'Log Out',
          style: GoogleFonts.manrope(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
