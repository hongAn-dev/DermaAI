import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

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
          'Subscription Management',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentPlanCard(),
            const SizedBox(height: 32),
            _buildSectionTitle('Quyền lợi theo gói bảo hiểm của bạn'),
            _buildBenefitItem(Icons.all_inclusive, 'Quét AI không giới hạn'),
            _buildBenefitItem(Icons.health_and_safety_outlined,
                'Tư vấn chuyên gia hàng tháng'),
            _buildBenefitItem(Icons.history_toggle_off, 'Lưu trữ lịch sử quét'),
            _buildBenefitItem(Icons.support_agent, 'Hỗ trợ ưu tiên'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18A0FB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('Kế hoạch nâng cấp'),
            ),
            const SizedBox(height: 24),
            Center(
                child: TextButton(
                    onPressed: () {},
                    child: Text('Quản lý phương thức thanh toán',
                        style: GoogleFonts.manrope(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)))),
            Center(
                child: TextButton(
                    onPressed: () {},
                    child: Text('Lịch sử giao dịch',
                        style: GoogleFonts.manrope(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)))),
            Center(
                child: TextButton(
                    onPressed: () {},
                    child: Text('Hủy đăng ký',
                        style: GoogleFonts.manrope(
                            color: Colors.red, fontWeight: FontWeight.w500)))),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Card(
      elevation: 1,
      shadowColor: colorWithOpacity(Colors.grey, 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gói cao cấp',
                    style: GoogleFonts.manrope(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Gia hạn vào ngày 25 tháng 12 năm 2024',
                    style: GoogleFonts.manrope(color: Colors.grey[600])),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Kích hoạt',
                  style: GoogleFonts.manrope(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorWithOpacity(const Color(0xFF18A0FB), 0.1),
          foregroundColor: const Color(0xFF18A0FB),
          child: Icon(icon, size: 20),
        ),
        title: Text(text,
            style:
                GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }
}
