import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController(); // Store as DD/MM/YYYY string
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _gender = 'Khác';
  String? _photoUrl;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _fullNameController.text = data['displayName'] ?? '';
        _dobController.text = data['birthDate'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _emailController.text = user.email ?? ''; // Email mainly from Auth
        _addressController.text = data['address'] ?? '';
        _gender = data['gender'] ?? 'Khác';
        _photoUrl = data['photoUrl'];
      } else {
        // Fallback to Auth data if no firestore doc
        _fullNameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _photoUrl = user.photoURL;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Update Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': _fullNameController.text.trim(),
        'birthDate': _dobController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _gender,
        'email': _emailController.text.trim(), // Keep email in sync
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update Auth Profile (DisplayName)
      await user.updateDisplayName(_fullNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                // Cancel
                setState(() {
                  _isEditing = false;
                  _fetchUserData(); // Re-fetch to reset fields
                });
              } else {
                // Start Editing
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Text(
              _isEditing ? 'Hủy' : 'Chỉnh sửa',
              style: GoogleFonts.manrope(
                  color: const Color(0xFF18A0FB),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAvatar(),
                const SizedBox(height: 32),
                _buildTextField('Họ và tên', _fullNameController),
                _buildDateField('Ngày sinh', _dobController),
                _buildGenderSelector(),
                _buildTextField('Số điện thoại', _phoneController),
                _buildTextField('Email', _emailController,
                    readOnly: true), // Email usually immutable
                const SizedBox(height: 32),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18A0FB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    child: const Text('Lưu thay đổi'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      if (_photoUrl!.startsWith('http')) {
        imageProvider = NetworkImage(_photoUrl!);
      } else if (_photoUrl!.startsWith('assets')) {
        imageProvider = AssetImage(_photoUrl!);
      }
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    _fullNameController.text.isNotEmpty
                        ? _fullNameController.text[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.manrope(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    final isEditable = _isEditing && !readOnly;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                  color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: !isEditable,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditable ? Colors.white : Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    // Simple text field for now, but enabling date picker icon if editing
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                  color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true, // Always read only, use picker
            onTap: _isEditing
                ? () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now());
                    if (pickedDate != null) {
                      // Format: DD/MM/YYYY
                      String formattedDate =
                          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      setState(() {
                        controller.text = formattedDate;
                      });
                    }
                  }
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing ? Colors.white : Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF18A0FB)),
                onPressed: _isEditing
                    ? () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                          setState(() {
                            controller.text = formattedDate;
                          });
                        }
                      }
                    : null, // Disable if not editing
              ),
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
          Text('Giới tính',
              style: GoogleFonts.manrope(
                  color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Nam', 'Nữ', 'Khác'].map((gender) {
              bool isSelected = _gender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: _isEditing
                      ? () => setState(() => _gender = gender)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF18A0FB) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? const Color(0xFF18A0FB)
                                : Colors.grey[300]!)),
                    child: Center(
                        child: Text(gender,
                            style: GoogleFonts.manrope(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black, // Fixed text color
                                fontWeight: FontWeight.w500))),
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
