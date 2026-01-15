import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import '../../models/doctor.dart';
import 'chat_screen.dart';

// --- Data Model ---

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

class ConsultPage extends StatefulWidget {
  const ConsultPage({super.key});

  @override
  State<ConsultPage> createState() => _ConsultPageState();
}

class _ConsultPageState extends State<ConsultPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(context),
                SizedBox(height: Responsive.scale(context, 12)),
                _buildSearchBar(), // Add Search Bar
                SizedBox(height: Responsive.scale(context, 12)),
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
                          child:
                              Text('Không có bác sĩ nào trong cơ sở dữ liệu'));
                    }
                    final doctors = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Doctor(
                        uid: doc.id,
                        name: data['displayName'] ?? 'Unknown Doctor',
                        specialization: data['specialization'] ?? 'General',
                        rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
                        reviewCount: data['reviewCount'] ?? 0,
                        nextAvailable: data['nextAvailable'] ?? 'Available now',
                        imagePath:
                            data['photoUrl'] ?? 'assets/images/doctor_1.png',
                      );
                    }).where((doctor) {
                      final query = _searchQuery.toLowerCase();
                      return doctor.name.toLowerCase().contains(query) ||
                          doctor.specialization.toLowerCase().contains(query);
                    }).toList();

                    if (doctors.isEmpty) {
                      return Center(
                          child:
                              Text('Không có bác sĩ nào trong cơ sở dữ liệu'));
                    }

                    return Column(
                      children: doctors.map((doctor) {
                        return _buildDoctorCard(context, doctor);
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: Responsive.scale(context, 20)),
                _buildInfoSection(context),
                SizedBox(height: Responsive.scale(context, 40)),
              ],
            ),
          ),
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
          backgroundImage: const AssetImage('assets/images/doctor_avatar.png'),
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
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
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
                  backgroundImage: doctor.imagePath.startsWith('http')
                      ? NetworkImage(doctor.imagePath)
                      : AssetImage(doctor.imagePath) as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    // Fallback handled by backgroundColor or could be improved later
                  },
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
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

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.scale(context, 24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF18A0FB), Color(0xFF5AB9F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18A0FB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chăm sóc làn da của bạn',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 24),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: Responsive.scale(context, 8)),
                Text(
                  'Kết nối với các bác sĩ da liễu hàng đầu ngay tại nhà.',
                  style: GoogleFonts.manrope(
                    fontSize: Responsive.fontSize(context, 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(Responsive.scale(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.health_and_safety_outlined,
                color: Colors.white, size: Responsive.scale(context, 40)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tại sao chọn DermaAI?',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 18))),
        SizedBox(height: Responsive.scale(context, 16)),
        Row(
          children: [
            _buildInfoCard(context, Icons.verified_user_outlined,
                'Bác sĩ uy tín', 'Đội ngũ bác sĩ được xác thực kỹ lưỡng.'),
            SizedBox(width: Responsive.scale(context, 12)),
            _buildInfoCard(context, Icons.security_outlined, 'Bảo mật',
                'Thông tin cá nhân được bảo vệ tuyệt đối.'),
            SizedBox(width: Responsive.scale(context, 12)),
            _buildInfoCard(context, Icons.support_agent_outlined, 'Hỗ trợ 24/7',
                'Luôn sẵn sàng giải đáp thắc mắc của bạn.'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        height: Responsive.scale(context, 140),
        padding: EdgeInsets.all(Responsive.scale(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.scale(context, 8)),
              decoration: BoxDecoration(
                color: const Color(0xFF18A0FB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: const Color(0xFF18A0FB),
                  size: Responsive.scale(context, 24)),
            ),
            SizedBox(height: Responsive.scale(context, 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 14),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 4)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 11),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
