import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceModel extends ChangeNotifier {
  bool _darkMode = false;
  double _fontSize = 16.0;
  bool _highContrast = true;
  String _iconStyle = 'Outlined';
  int _accentColorValue = 0xFF18A0FB;

  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;
  bool get highContrast => _highContrast;
  String get iconStyle => _iconStyle;
  int get accentColorValue => _accentColorValue;

  double get fontScale => _fontSize / 16.0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('appearance_darkMode') ?? _darkMode;
    _fontSize = prefs.getDouble('appearance_fontSize') ?? _fontSize;
    _highContrast = prefs.getBool('appearance_highContrast') ?? _highContrast;
    _iconStyle = prefs.getString('appearance_iconStyle') ?? _iconStyle;
    _accentColorValue =
        prefs.getInt('appearance_accentColor') ?? _accentColorValue;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appearance_darkMode', _darkMode);
    await prefs.setDouble('appearance_fontSize', _fontSize);
    await prefs.setBool('appearance_highContrast', _highContrast);
    await prefs.setString('appearance_iconStyle', _iconStyle);
    await prefs.setInt('appearance_accentColor', _accentColorValue);
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await _save();
    notifyListeners();
  }

  Future<void> setFontSize(double v) async {
    _fontSize = v;
    await _save();
    notifyListeners();
  }

  Future<void> setHighContrast(bool v) async {
    _highContrast = v;
    await _save();
    notifyListeners();
  }

  Future<void> setIconStyle(String v) async {
    _iconStyle = v;
    await _save();
    notifyListeners();
  }

  Future<void> setAccentColor(int v) async {
    _accentColorValue = v;
    await _save();
    notifyListeners();
  }
}
