import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // A map to associate routes with their titles and icons
    final settingsItems = {
      'TÀI KHOẢN': [
        {
          'icon': Icons.person_outline,
          'title': 'Thông tin cá nhân',
          'route': '/profile/personal_information'
        },
        {
          'icon': Icons.subscriptions_outlined,
          'title': 'Quản lý đăng ký',
          'route': '/profile/subscription'
        },
      ],
      'BẢO MẬT & QUYỀN RIÊNG TƯ': [
        {
          'icon': Icons.lock_outline,
          'title': 'Thay đổi mật khẩu',
          'route': '/profile/change_password'
        },
        {
          'icon': Icons.shield_outlined,
          'title': 'Chính sách bảo mật',
          'route': '/profile/privacy_policy'
        },
        {
          'icon': Icons.article_outlined,
          'title': 'Điều khoản dịch vụ',
          'route': '/profile/terms_of_service'
        },
      ],
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'), // Navigate back to home
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hồ sơ & Cài đặt',
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 24),
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.scale(context, 16.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user, context),
                SizedBox(height: Responsive.scale(context, 24)),
                ...settingsItems.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, entry.key),
                      _buildSettingsCard(
                        context,
                        entry.value.map((item) {
                          return _buildSettingsItem(
                            context,
                            item['icon'] as IconData,
                            item['title'] as String,
                            () => context.go(item['route'] as String),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: Responsive.scale(context, 24)),
                    ],
                  );
                }),
                SizedBox(height: Responsive.scale(context, 8)),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user, BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String displayName = user.displayName ?? 'No Name';
          String email = user.email ?? 'No Email';
          String? photoUrl = user.photoURL;

          // Use Firestore data if available, as it might be fresher or have more fields if we decided to diverge
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data.containsKey('displayName'))
              displayName = data['displayName'];
            // email is usually Auth managed, but if stored in DB:
            if (data.containsKey('email')) email = data['email'];
            if (data.containsKey('photoUrl')) photoUrl = data['photoUrl'];
          }

          ImageProvider? backgroundImage;
          if (photoUrl != null && photoUrl.isNotEmpty) {
            if (photoUrl.startsWith('http')) {
              backgroundImage = NetworkImage(photoUrl);
            } else if (photoUrl.startsWith('assets')) {
              backgroundImage = AssetImage(photoUrl);
            }
          }

          return Container(
            padding: EdgeInsets.all(Responsive.scale(context, 16.0)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(Responsive.scale(context, 12.0)),
              boxShadow: [
                BoxShadow(
                  color: colorWithOpacity(Colors.grey, 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: Responsive.avatarRadius(context, base: 30),
                  backgroundColor: Colors.grey[200],
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        )
                      : null,
                ),
                SizedBox(width: Responsive.scale(context, 16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 18),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 4)),
                    Text(
                      email,
                      style: GoogleFonts.manrope(
                        color: Colors.grey[600],
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: const Color(0xFF18A0FB),
                  radius: Responsive.avatarRadius(context, base: 20),
                  child: IconButton(
                    icon: Icon(Icons.edit,
                        color: Colors.white,
                        size: Responsive.scale(context, 16)),
                    onPressed: () =>
                        context.go('/profile/personal_information'),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
          left: Responsive.scale(context, 8.0),
          bottom: Responsive.scale(context, 8.0)),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: Responsive.fontSize(context, 12),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 12.0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF18A0FB)),
      title: Text(
        title,
        style: GoogleFonts.manrope(
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: Responsive.scale(context, 16), color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          context.go('/login');
        },
        child: Text(
          'Đăng xuất',
          style: GoogleFonts.manrope(
            color: Colors.red,
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
