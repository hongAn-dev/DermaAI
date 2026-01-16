import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import 'package:myapp/utils/color_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Thêm controller
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  // State added
  String _gender = 'Khác';
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
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate basics
    if (_displayNameController.text.trim().isEmpty) {
      _setError('Vui lòng nhập họ và tên.');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _setError('Vui lòng nhập số điện thoại.');
      return;
    }
    if (_dobController.text.trim().isEmpty) {
      _setError('Vui lòng chọn ngày sinh.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _setError('Mật khẩu không khớp.');
      return;
    }

    final success = await context.read<AuthViewModel>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
          role: _role,
          phoneNumber: _phoneController.text.trim(),
          birthDate: _dobController.text.trim(),
          gender: _gender,
        );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = context.read<AuthViewModel>().errorMessage;
      _setError(error ?? 'Đăng ký thất bại');
    }
  }

  void _setError(String msg) {
    setState(() {
      _errorMessage = msg;
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 32.0,
                    backgroundColor:
                        colorWithOpacity(const Color(0xFF18A0FB), 0.2),
                    child: const Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Color(0xFF18A0FB),
                      size: 32.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tạo tài khoản',
                    style: GoogleFonts.manrope(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: _displayNameController,
                    hintText: 'Họ và tên',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  // Date of Birth
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                        setState(() {
                          _dobController.text = formattedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Ngày sinh (DD/MM/YYYY)',
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gender
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.grey
                                .shade400) // Match default border color approx
                        ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _gender,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.grey),
                        items: ['Nam', 'Nữ', 'Khác'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(children: [
                              Icon(
                                  value == 'Nam'
                                      ? Icons.male
                                      : (value == 'Nữ'
                                          ? Icons.female
                                          : Icons.transgender),
                                  color: Colors.grey,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(value, style: GoogleFonts.manrope()),
                            ]),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _gender = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Số điện thoại',
                    prefixIcon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 12),

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

                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    items: const [
                      DropdownMenuItem(
                          value: 'user', child: Text('Người dùng')),
                      DropdownMenuItem(value: 'doctor', child: Text('Bác sĩ')),
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
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18A0FB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                  const SizedBox(height: 32),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
