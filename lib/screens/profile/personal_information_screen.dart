
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _fullNameController = TextEditingController(text: 'John Doe');
  final _dobController = TextEditingController(text: '01/01/1990');
  final _phoneController = TextEditingController(text: '(123) *** 4567');
  final _emailController = TextEditingController(text: 'johndoe@email.com');

  String _gender = 'Male';
  bool _isEditing = false;

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
          'Thông tin cá nhân',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Hủy' : 'Chỉnh sửa',
              style: GoogleFonts.manrope(color: const Color(0xFF18A0FB), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatar(),
            const SizedBox(height: 32),
            _buildTextField('Họ và tên', _fullNameController),
            _buildDateField('Ngày sinh', _dobController),
            _buildGenderSelector(),
            _buildTextField('Số điện thoại', _phoneController, readOnly: !_isEditing),
            _buildTextField('Email', _emailController, readOnly: !_isEditing),
            const SizedBox(height: 32),
            if (_isEditing)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18A0FB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: const Text('Lưu thay đổi'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=john.doe'),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF18A0FB),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: () { /* TODO: Implement image picker */ },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.manrope(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly && !_isEditing,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly && !_isEditing ? Colors.grey[200] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.manrope(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              suffixIcon: _isEditing ? IconButton(
                icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF18A0FB)),
                onPressed: () { /* TODO: Implement date picker */ },
              ) : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giới tính', style: GoogleFonts.manrope(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Nam', 'Nữ', 'Khác'].map((gender) {
              bool isSelected = _gender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: _isEditing ? () => setState(() => _gender = gender) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF18A0FB) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? const Color(0xFF18A0FB) : Colors.grey[300]!)
                    ),
                    child: Center(child: Text(gender, style: GoogleFonts.manrope(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
