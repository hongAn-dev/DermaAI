
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _darkMode = false;
  double _fontSize = 16.0;
  bool _highContrast = true;
  String _iconStyle = 'Outlined';

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
          'Appearance',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('APPEARANCE'),
            _buildSettingsCard([
              _buildSwitchTile(Icons.dark_mode_outlined, 'Dark Mode', _darkMode, (value) => setState(() => _darkMode = value)),
              _buildNavigationTile(Icons.color_lens_outlined, 'Accent Color'),
              _buildToggleTile(Icons.touch_app_outlined, 'Icon Style'),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('TEXT'),
            _buildSettingsCard([
              _buildSliderTile(Icons.format_size, 'Font Size'),
              _buildSwitchTile(Icons.contrast_outlined, 'High Contrast Text', _highContrast, (value) => setState(() => _highContrast = value)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF18A0FB),
      ),
    );
  }

  Widget _buildNavigationTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF18A0FB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () { /* TODO: Navigate to color picker */ },
    );
  }

  Widget _buildToggleTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: ToggleButtons(
        isSelected: [_iconStyle == 'Outlined', _iconStyle == 'Filled'],
        onPressed: (index) {
          setState(() {
            _iconStyle = index == 0 ? 'Outlined' : 'Filled';
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        color: const Color(0xFF18A0FB),
        fillColor: const Color(0xFF18A0FB),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
        children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Outlined')), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Filled'))],
      ),
    );
  }

  Widget _buildSliderTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: Colors.grey[700]),
            title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 16)),
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            label: _fontSize.round().toString(),
            onChanged: (value) => setState(() => _fontSize = value),
            activeColor: const Color(0xFF18A0FB),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A-', style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 12)),
              Text('A+', style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 20)),
            ],
          )
        ],
      ),
    );
  }
}
