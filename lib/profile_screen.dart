import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/responsive_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ResponsiveScaffold(
      selectedIndex: 3, // Index for Profile/Settings
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // No back button needed as navigation is handled by the scaffold
          title: Text(
            'Settings',
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
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildSectionTitle('ACCOUNT'),
                  _buildSettingsCard([
                    _buildSettingsItem(Icons.person_outline, 'Personal Information', () {}),
                    _buildSettingsItem(Icons.subscriptions_outlined, 'Manage Subscription', () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('PREFERENCES'),
                  _buildSettingsCard([
                    _buildSwitchItem(Icons.notifications_outlined, 'Push Notifications', true, (value) {}),
                    _buildSettingsItem(Icons.palette_outlined, 'Appearance', () {}, trailing: 'System'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SECURITY & PRIVACY'),
                  _buildSettingsCard([
                    _buildSwitchItem(Icons.fingerprint, 'Enable Face ID', false, (value) {}),
                    _buildSettingsItem(Icons.lock_outline, 'Change Password', () {}),
                    _buildSettingsItem(Icons.shield_outlined, 'Privacy Policy', () {}),
                    _buildSettingsItem(Icons.article_outlined, 'Terms of Service', () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SUPPORT'),
                  _buildSettingsCard([
                    _buildSettingsItem(Icons.help_outline, 'Help Center', () {}),
                    _buildSettingsItem(Icons.contact_support_outlined, 'Contact Us', () {}),
                    _buildSettingsItem(Icons.info_outline, 'About this App', () {}),
                  ]),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
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
              onPressed: () {},
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

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {String? trailing}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF18A0FB)),
      title: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600]),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF18A0FB)),
      title: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF18A0FB),
      ),
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
