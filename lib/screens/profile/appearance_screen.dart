import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/appearance_model.dart';
import 'package:myapp/utils/responsive.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final appearance = Provider.of<AppearanceModel>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Giao diện',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: Responsive.fontSize(context, 18)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.scale(context, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('GIAO DIỆN'),
            _buildSettingsCard([
                _buildSwitchTile(
                  Icons.dark_mode_outlined,
                  'Chế độ tối',
                  appearance.darkMode,
                  (value) => appearance.setDarkMode(value)),
                _buildNavigationTile(Icons.color_lens_outlined, 'Màu chủ đạo'),
                _buildToggleTile(Icons.touch_app_outlined, 'Kiểu biểu tượng'),
            ]),
            const SizedBox(height: 12),
            _buildPreviewCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('VĂN BẢN'),
            _buildSettingsCard([
                _buildSliderTile(Icons.format_size, 'Kích thước chữ'),
                _buildSwitchTile(
                  Icons.contrast_outlined,
                  'Chữ tương phản cao',
                  appearance.highContrast,
                  (value) => appearance.setHighContrast(value)),
            ]),
          ],
        ),
      ),
    );
  }

  // Appearance values are driven by AppearanceModel (Provider)

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Responsive.scale(context, 8),
          Responsive.scale(context, 8),
          Responsive.scale(context, 8),
          Responsive.scale(context, 12)),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: Responsive.fontSize(context, 12),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 12.0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title,
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: Responsive.fontSize(context, 16))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF18A0FB),
      ),
    );
  }

  Widget _buildNavigationTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title,
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: Responsive.fontSize(context, 16))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<AppearanceModel>(builder: (context, appearance, _) {
            return Container(
              width: Responsive.scale(context, 24),
              height: Responsive.scale(context, 24),
              decoration: BoxDecoration(
                color: Color(appearance.accentColorValue),
                shape: BoxShape.circle,
              ),
            );
          }),
          SizedBox(width: Responsive.scale(context, 8)),
          Icon(Icons.arrow_forward_ios,
              size: Responsive.scale(context, 16), color: Colors.grey),
        ],
      ),
      onTap: () => _pickAccentColor(context),
    );
  }

  Widget _buildToggleTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title,
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: Responsive.fontSize(context, 16))),
      trailing: Consumer<AppearanceModel>(builder: (context, appearance, _) {
        return ToggleButtons(
          isSelected: [
            appearance.iconStyle == 'Outlined',
            appearance.iconStyle == 'Filled'
          ],
          onPressed: (index) {
            final model = Provider.of<AppearanceModel>(context, listen: false);
            final newStyle = index == 0 ? 'Outlined' : 'Filled';
            model.setIconStyle(newStyle);
          },
          borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
          selectedColor: Colors.white,
          color: Color(appearance.accentColorValue),
          fillColor: Color(appearance.accentColorValue),
          constraints: BoxConstraints(
              minHeight: Responsive.scale(context, 32),
              minWidth: Responsive.scale(context, 60)),
            children: const [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Viền')),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Đậm'))
          ],
        );
      }),
    );
  }

  Widget _buildSliderTile(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16),
          vertical: Responsive.scale(context, 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: Colors.grey[700]),
            title: Text(title,
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w500,
                    fontSize: Responsive.fontSize(context, 16))),
          ),
          Consumer<AppearanceModel>(builder: (context, appearance, _) {
            return Slider(
              value: appearance.fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: appearance.fontSize.round().toString(),
              onChanged: (value) => appearance.setFontSize(value),
              activeColor: Color(appearance.accentColorValue),
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A-',
                  style: GoogleFonts.manrope(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 12))),
              Text('A+',
                  style: GoogleFonts.manrope(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 20))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Consumer<AppearanceModel>(builder: (context, appearance, _) {
      final accent = Color(appearance.accentColorValue);
      final textColor = appearance.highContrast
          ? (appearance.darkMode ? Colors.white : Colors.black)
          : Colors.grey[800];
      return Container(
        margin: EdgeInsets.symmetric(vertical: Responsive.scale(context, 8)),
        padding: EdgeInsets.all(Responsive.scale(context, 12)),
        decoration: BoxDecoration(
          color: appearance.darkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.scale(context, 56),
              height: Responsive.scale(context, 56),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                appearance.iconStyle == 'Outlined'
                    ? Icons.person_outline
                    : Icons.person,
                color: Colors.white,
              ),
            ),
            SizedBox(width: Responsive.scale(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('Tiêu đề xem trước',
                      style: GoogleFonts.manrope(
                          fontSize: appearance.fontSize + 2,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  SizedBox(height: Responsive.scale(context, 6)),
                    Text('Đây là bản xem trước cỡ chữ và tương phản.',
                      style: GoogleFonts.manrope(
                          fontSize: appearance.fontSize, color: textColor)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                  appearance.iconStyle == 'Outlined'
                      ? Icons.star_border
                      : Icons.star,
                  color: accent),
            )
          ],
        ),
      );
    });
  }

  Future<void> _pickAccentColor(BuildContext context) async {
    final colors = [
      0xFF18A0FB,
      0xFF6C63FF,
      0xFFFF6B6B,
      0xFF00C896,
      0xFFFFC107,
      0xFF9C27B0,
      0xFF607D8B,
      0xFF4CAF50,
    ];

        await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chọn màu chủ đạo', style: GoogleFonts.manrope()),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: colors.map((c) {
              return InkWell(
                onTap: () {
                  final model =
                      Provider.of<AppearanceModel>(context, listen: false);
                  model.setAccentColor(c);
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!)),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Hủy', style: GoogleFonts.manrope())),
        ],
      ),
    );
  }
}
