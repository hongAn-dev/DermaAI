import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/color_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  String _errorMessage = '';

  // --- HÀM 1: GỬI YÊU CẦU RESET PASS ---
  Future<void> _sendResetEmail(String email) async {
    try {
      // Hiện loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      if (!mounted) return;
      Navigator.of(context).pop(); // Tắt loading
      Navigator.of(context).pop(); // Tắt dialog nhập email

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi link đổi mật khẩu tới $email'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tắt loading

      String msg = 'Lỗi không xác định';
      if (e.code == 'user-not-found') msg = 'Email này chưa đăng ký tài khoản.';
      if (e.code == 'invalid-email') msg = 'Email không hợp lệ.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM 2: HIỆN HỘP THOẠI NHẬP EMAIL ---
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    // Tự động điền email nếu người dùng đã nhập ở màn hình ngoài
    if (_emailController.text.isNotEmpty) {
      resetEmailController.text = _emailController.text;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đặt lại mật khẩu',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Nhập email của bạn để nhận đường dẫn đặt lại mật khẩu.'),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: 'Nhập email của bạn',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.isEmpty) return;
              _sendResetEmail(resetEmailController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18A0FB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Việt hóa một vài lỗi phổ biến
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _errorMessage = 'Email hoặc mật khẩu không chính xác.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Định dạng email không hợp lệ.';
        } else {
          _errorMessage = e.message ?? 'Đã xảy ra lỗi.';
        }
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
                        Icons.security,
                        color: Color(0xFF18A0FB),
                        size: 40.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đăng nhập',
                      style: GoogleFonts.manrope(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // --- NÚT QUÊN MẬT KHẨU ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _showForgotPasswordDialog, // <--- GỌI HÀM Ở ĐÂY
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Color(0xFF18A0FB)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18A0FB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Đăng nhập',
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
                          const TextSpan(text: 'Chưa có tài khoản? '),
                          TextSpan(
                            text: 'Đăng ký',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18A0FB),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/register'),
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
}
