import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // 1. Khai báo Form Key và Controllers để lấy dữ liệu
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Trạng thái loading

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // 2. Hàm xử lý logic đổi mật khẩu
  Future<void> _changePassword() async {
    // Kiểm tra form hợp lệ chưa (không rỗng, pass trùng nhau...)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPassController.text.trim(),
    );

    try {
      // BƯỚC 1: Xác thực lại người dùng bằng mật khẩu cũ
      await user.reauthenticateWithCredential(cred);

      // BƯỚC 2: Cập nhật mật khẩu mới
      await user.updatePassword(_newPassController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Quay lại màn hình trước
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Mật khẩu hiện tại không đúng.';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu mới quá yếu.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Vui lòng đăng nhập lại trước khi đổi mật khẩu.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          'Thay đổi mật khẩu',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                // Bọc trong Form widget
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPasswordField(
                      controller: _currentPassController,
                      label: 'Mật khẩu hiện tại',
                      hint: 'Nhập mật khẩu hiện tại',
                      obscureText: _obscureCurrentPassword,
                      onToggle: () => setState(() =>
                          _obscureCurrentPassword = !_obscureCurrentPassword),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Vui lòng nhập mật khẩu cũ'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPassController,
                      label: 'Mật khẩu mới',
                      hint: 'Nhập mật khẩu mới',
                      obscureText: _obscureNewPassword,
                      onToggle: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nhập mật khẩu mới';
                        }
                        if (val.length < 6) return 'Mật khẩu phải trên 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _confirmPassController,
                      label: 'Xác nhận mật khẩu mới',
                      hint: 'Nhập mật khẩu mới',
                      obscureText: _obscureConfirmPassword,
                      onToggle: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                      validator: (val) {
                        if (val != _newPassController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mật khẩu phải có ít nhất 6 ký tự.',
                      style: GoogleFonts.manrope(
                          color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _changePassword, // Khóa nút khi đang load
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18A0FB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu thay đổi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller, // Thêm controller vào đây
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator, // Thêm validator
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Gắn controller
          obscureText: obscureText,
          validator: validator, // Gắn logic kiểm tra lỗi
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF18A0FB)),
            ),
            errorBorder: OutlineInputBorder(
              // Viền đỏ khi lỗi
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
