import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/responsive_scaffold.dart';

// --- Data Model ---
class Doctor {
  final String name;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String nextAvailable;
  final String imagePath;

  Doctor({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.nextAvailable,
    required this.imagePath,
  });
}

// --- Main Screen Widget ---
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  // --- Mock Data ---
  static final List<Doctor> doctors = [
    Doctor(
      name: 'Dr. Evelyn Reed, MD',
      specialization: 'Board-Certified Dermatologist',
      rating: 4.9,
      reviewCount: 124,
      nextAvailable: 'Today, 4:30 PM',
      imagePath: 'assets/images/doctor1.png', // Placeholder
    ),
    Doctor(
      name: 'Dr. Marcus Chen, FAAD',
      specialization: 'Pediatric & Cosmetic Dermatology',
      rating: 4.8,
      reviewCount: 98,
      nextAvailable: 'Tomorrow, 9:00 AM',
      imagePath: 'assets/images/doctor2.png', // Placeholder
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      selectedIndex: 2, // Correct index for Consult
      child: ConsultPage(),
    );
  }
}

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Consult an Expert',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get a professional opinion on your AI analysis. Connect with a board-certified dermatologist.',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            ...ConsultScreen.doctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionChip(Icons.video_camera_front_outlined, 'Video Call'),
        _buildActionChip(Icons.calendar_today_outlined, 'Schedule'),
        _buildActionChip(Icons.message_outlined, 'Message'),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue.shade800, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name, specialty...',
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

  Widget _buildFilterChips() {
    final filters = ['Available Now', 'Top Rated', 'Pediatric', 'More'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Chip(
            label: Text(filters[index]),
            backgroundColor: isSelected ? const Color(0xFF18A0FB) : Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

   Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[200],
                  // TODO: Add doctor images to assets
                  // backgroundImage: AssetImage(doctor.imagePath),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(doctor.specialization, style: GoogleFonts.manrope(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${doctor.rating} (${doctor.reviewCount} reviews)', style: GoogleFonts.manrope()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Next available', style: GoogleFonts.manrope()),
                  Text(doctor.nextAvailable, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Schedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF18A0FB),
                      side: const BorderSide(color: Color(0xFF18A0FB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.video_camera_front),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18A0FB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
