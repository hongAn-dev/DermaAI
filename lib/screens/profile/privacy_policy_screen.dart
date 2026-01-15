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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cập nhật lần cuối: ngày 24 tháng 5 năm 2024',
                style: GoogleFonts.manrope(color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildSection('Giới thiệu',
                'Chính sách này mô tả cách chúng tôi thu thập, sử dụng và bảo vệ thông tin cá nhân của bạn khi bạn sử dụng ứng dụng chẩn đoán da liễu bằng trí tuệ nhân tạo của chúng tôi.'),
            _buildSection('1. Thu thập thông tin',
                'Chúng tôi thu thập thông tin mà bạn cung cấp trực tiếp cho chúng tôi, chẳng hạn như khi bạn tạo tài khoản, tải hình ảnh lên để phân tích hoặc liên hệ với chúng tôi để được hỗ trợ. Thông tin này có thể bao gồm tên, địa chỉ email và hình ảnh da liễu của bạn.'),
            _buildSection('2. Sử dụng thông tin',
                'Thông tin của bạn được sử dụng để cung cấp và cải thiện dịch vụ của chúng tôi, huấn luyện các mô hình AI và liên lạc với bạn về các bản cập nhật quan trọng. Chúng tôi cam kết ẩn danh dữ liệu hình ảnh được sử dụng cho mục đích nghiên cứu.'),
            _buildSection('3. Chia sẻ và tiết lộ dữ liệu',
                'Chúng tôi không bán thông tin cá nhân của bạn. Dữ liệu có thể được chia sẻ với các đối tác nghiên cứu hoặc nhà cung cấp dịch vụ bên thứ ba theo các thỏa thuận bảo mật nghiêm ngặt.'),
            _buildSection('4. Bảo mật dữ liệu',
                'Chúng tôi áp dụng các biện pháp bảo mật kỹ thuật và tổ chức để bảo vệ dữ liệu của bạn khỏi sự truy cập, sửa đổi hoặc phá hủy trái phép.'),
            _buildSection('5. Quyền của người dùng',
                'Bạn có quyền truy cập, chỉnh sửa hoặc xóa thông tin cá nhân của mình. Bạn có thể thực hiện các quyền này thông qua cài đặt tài khoản hoặc bằng cách liên hệ với chúng tôi.'),
            _buildSection('6. Liên hệ với chúng tôi',
                'Nếu bạn có bất kỳ thắc mắc nào về chính sách bảo mật này, vui lòng liên hệ với chúng tôi qua email: privacy@skinai.app.'),
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
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.manrope(
                fontSize: 15, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
