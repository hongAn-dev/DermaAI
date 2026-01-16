import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
// import '../../models/doctor.dart'; // Remove old model
import '../../data/models/doctor_model.dart'; // Add new model
import '../../view_models/consult_view_model.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads to handle re-login scenarios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultViewModel>().refreshDoctors();
    });
  }

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
                        onPressed: () {
                          _showAllDoctors(context,
                              context.read<ConsultViewModel>().doctors);
                        },
                        child: Text('Xem tất cả',
                            style: GoogleFonts.manrope(
                                color: const Color(0xFF18A0FB)))),
                  ],
                ),
                SizedBox(height: Responsive.scale(context, 12)),
                // List
                Consumer<ConsultViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.errorMessage != null) {
                      return Center(
                          child: Text('Lỗi: ${viewModel.errorMessage}'));
                    }

                    if (viewModel.doctors.isEmpty) {
                      return const Center(
                          child: Text('Không tìm thấy bác sĩ nào'));
                    }

                    // Limit to 3 items
                    final displayedDoctors = viewModel.doctors.take(3).toList();

                    return Column(
                      children: displayedDoctors.map((doctor) {
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        context.read<ConsultViewModel>().search(value);
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

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatScreen(doctor: doctor),
        ));
      },
      child: Container(
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
                    backgroundColor: Colors
                        .transparent, // Transparent to show default image correctly
                    backgroundImage: (doctor.imagePath.startsWith('http') ||
                            doctor.imagePath.startsWith('assets'))
                        ? (doctor.imagePath.startsWith('http')
                            ? NetworkImage(doctor.imagePath)
                            : AssetImage(doctor.imagePath) as ImageProvider)
                        : null,
                    onBackgroundImageError: (_, __) {
                      // Image failed, child text will show
                    },
                    child: (doctor.imagePath.trim().isEmpty ||
                            (doctor.imagePath.startsWith('http') == false &&
                                doctor.imagePath.startsWith('assets') == false))
                        ? Image.asset('assets/images/doctor_avatar.png',
                            fit: BoxFit.cover)
                        : null,
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
              ),
            ],
          ),
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

  void _showAllDoctors(BuildContext context, List<Doctor> doctors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header of BottomSheet
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Tất cả bác sĩ',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(context, doctors[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
