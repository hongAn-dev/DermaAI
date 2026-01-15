import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Điều Khoản Dịch Vụ',
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
            Text('Cập nhật lần cuối: 23 Tháng 10, 2023',
                style: GoogleFonts.manrope(color: Colors.grey[600])),
            const SizedBox(height: 16),
            _buildExpansionTile('Giới thiệu',
                'Tài liệu này là thỏa thuận ràng buộc giữa người dùng và nhà cung cấp dịch vụ. Bằng cách sử dụng ứng dụng, bạn đồng ý với các điều khoản được mô tả ở đây.'),
            _buildExpansionTile('Quyền riêng tư',
                'Chính sách Quyền riêng tư của chúng tôi (có trên trang web) giải thích cách chúng tôi thu thập, sử dụng và bảo vệ thông tin cá nhân của bạn.'),
            _buildExpansionTile('Trách nhiệm của người dùng',
                'Bạn đồng ý sử dụng ứng dụng chỉ cho các mục đích hợp pháp và không được hành vi làm tổn hại hoặc cản trở quyền lợi của người khác khi sử dụng ứng dụng.'),
            _buildExpansionTile(
              'Phạm vi dịch vụ & Giới hạn AI',
              'Công nghệ AI của chúng tôi cung cấp các đề xuất dựa trên hình ảnh bạn cung cấp. Tuy nhiên, kết quả không phải là chẩn đoán y tế chính thức và có thể không hoàn toàn chính xác. Luôn tham khảo ý kiến chuyên gia y tế khi cần.',
              initiallyExpanded: true,
            ),
            _buildExpansionTile('Sở hữu trí tuệ',
                'Toàn bộ nội dung và phần mềm liên quan đến ứng dụng là tài sản của DermAI Inc. hoặc bên cấp phép.'),
            _buildExpansionTile('Miễn trừ bảo đảm',
                'Dịch vụ được cung cấp "như hiện có" mà không có bất kỳ bảo đảm nào, rõ ràng hay ngụ ý...'),
            _buildExpansionTile('Giới hạn trách nhiệm',
                'DermAI Inc. sẽ không chịu trách nhiệm cho bất kỳ thiệt hại gián tiếp, ngẫu nhiên, đặc biệt, hệ quả hoặc trừng phạt phát sinh...'),
            _buildExpansionTile('Thông tin liên hệ',
                'Nếu bạn có bất kỳ câu hỏi nào về các Điều khoản này, vui lòng liên hệ chúng tôi tại contact@dermai.app.'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content,
      {bool initiallyExpanded = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title,
            style:
                GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: GoogleFonts.manrope(color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
