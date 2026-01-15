import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/realtime_service.dart';
import 'package:myapp/utils/color_utils.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Thêm controller cho tên hiển thị
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  String _role = 'user';

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate tên hiển thị
    if (_displayNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên hiển thị.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Mật khẩu không khớp.';
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text);

      final user = credential.user ?? FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Cập nhật display name cho chính user trong Auth (tuỳ chọn, nhưng nên làm)
        await user.updateDisplayName(_displayNameController.text.trim());

        // 2. Chuẩn bị dữ liệu user (Bao gồm password và display name từ controller)
        final userData = {
          'displayName':
              _displayNameController.text.trim(), // Lấy từ controller
          'email': user.email ?? _emailController.text,
          'password': _passwordController.text, // Thêm password theo yêu cầu
          'role': _role,
        };

        try {
          // Ghi vào Realtime DB
          await RealtimeService().ensureUser(user.uid, userData);
        } catch (e) {
          // ignore: avoid_print
          print('Realtime DB write failed: $e');
          setState(() {
            _errorMessage = 'Không thể ghi dữ liệu Realtime DB: $e';
          });
        }

        try {
          // Ghi vào Firestore (Thêm createdAt)
          await FirestoreService().ensureUserDoc(user.uid, {
            ...userData,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // ignore: avoid_print
          print('Firestore user doc write failed: $e');
          setState(() {
            _errorMessage = 'Không thể ghi dữ liệu Firestore: $e';
          });
        }
      }

      if (!mounted) return;

      if (_errorMessage.isNotEmpty) return;

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Đã xảy ra lỗi không xác định.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor:
                          colorWithOpacity(const Color(0xFF18A0FB), 0.2),
                      child: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Color(0xFF18A0FB),
                        size: 40.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tạo tài khoản',
                      style: GoogleFonts.manrope(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. UI: Thêm trường nhập Tên hiển thị
                    _buildTextField(
                      controller: _displayNameController,
                      hintText: 'Tên hiển thị',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      controller: _passwordController,
                      hintText: 'Mật khẩu',
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Nhập lại mật khẩu',
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Role selector
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                        DropdownMenuItem(
                            value: 'doctor', child: Text('Bác sĩ')),
                      ],
                      onChanged: (v) => setState(() => _role = v ?? 'user'),
                      decoration: InputDecoration(
                        labelText: 'Vai trò',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18A0FB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Đăng ký',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF6C757D),
                        ),
                        children: [
                          const TextSpan(text: 'Đã có tài khoản? '),
                          TextSpan(
                            text: 'Đăng nhập',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18A0FB),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
