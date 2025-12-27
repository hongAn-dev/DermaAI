import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import 'chat_screen.dart';

// --- Data Model ---
class Doctor {
  final String name;
  final String specialization;
  final String uid;
  final double rating;
  final int reviewCount;
  final String nextAvailable;
  final String imagePath;

  Doctor({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.nextAvailable,
    required this.imagePath,
  });
}

// --- Main Screen Widget ---
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      selectedIndex: 2, // Correct index for Consult
      child: ConsultPage(),
    );
  }
}

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Tư vấn từ xa',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: Responsive.fontSize(context, 20)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bác sĩ được đề xuất',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 20))),
                TextButton(
                    onPressed: () {},
                    child: Text('Xem tất cả',
                        style: GoogleFonts.manrope(
                            color: const Color(0xFF18A0FB)))),
              ],
            ),
            SizedBox(height: Responsive.scale(context, 12)),
            // List
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'doctor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Lỗi tải bác sĩ: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                // debug log
                // ignore: avoid_print
                print('ConsultScreen: found ${docs.length} doctor docs');
                if (docs.isEmpty) {
                  return Center(
                      child: Text('Không có bác sĩ nào trong cơ sở dữ liệu'));
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final doctor = Doctor(
                      uid: doc.id,
                      name: (data['displayName'] as String?) ?? 'Unknown',
                      specialization:
                          (data['specialization'] as String?) ?? 'Dermatology',
                      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
                      reviewCount: (data['reviewCount'] as int?) ?? 0,
                      nextAvailable: (data['nextAvailable'] as String?) ?? '',
                      imagePath: (data['photoUrl'] as String?) ??
                          'assets/images/doctor1.png',
                    );
                    return _buildDoctorCard(context, doctor);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionChip(
            context, Icons.video_camera_front_outlined, 'Gọi video'),
        _buildActionChip(context, Icons.calendar_today_outlined, 'Lịch hẹn'),
        _buildActionChip(context, Icons.message_outlined, 'Tin nhắn'),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: Responsive.avatarRadius(context, base: 30),
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon,
              color: Colors.blue.shade800, size: Responsive.scale(context, 28)),
        ),
        SizedBox(height: Responsive.scale(context, 8)),
        Text(label,
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.fontSize(context, 12))),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm theo tên, chuyên khoa...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['Có sẵn', 'Được đánh giá cao', 'Nhi khoa', 'Thêm'];
    return SizedBox(
      height: Responsive.scale(context, 40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Chip(
            label: Text(filters[index]),
            backgroundColor:
                isSelected ? const Color(0xFF18A0FB) : Colors.white,
            labelStyle:
                TextStyle(color: isSelected ? Colors.white : Colors.black),
            side: isSelected
                ? BorderSide.none
                : BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Responsive.scale(context, 20))),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.scale(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        boxShadow: [
          BoxShadow(
              color: colorWithOpacity(Colors.grey, 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 14),
            vertical: Responsive.scale(context, 12)),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: Responsive.avatarRadius(context, base: 36),
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: Responsive.scale(context, 14),
                    height: Responsive.scale(context, 14),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white,
                            width: Responsive.scale(context, 2))),
                  ),
                )
              ],
            ),
            SizedBox(width: Responsive.scale(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 18))),
                  SizedBox(height: Responsive.scale(context, 6)),
                  Text(doctor.specialization.toUpperCase(),
                      style: GoogleFonts.manrope(
                          color: const Color(0xFF18A0FB),
                          fontSize: Responsive.fontSize(context, 12),
                          letterSpacing: 0.6)),
                  SizedBox(height: Responsive.scale(context, 8)),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: Colors.amber,
                          size: Responsive.scale(context, 16)),
                      SizedBox(width: Responsive.scale(context, 8)),
                      Text('${doctor.rating}',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.fontSize(context, 14))),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(width: Responsive.scale(context, 12)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatScreen(doctor: doctor)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18A0FB),
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scale(context, 20),
                        vertical: Responsive.scale(context, 10)),
                    elevation: 0,
                  ),
                  child: Text('Trò chuyện',
                      style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.fontSize(context, 14))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
