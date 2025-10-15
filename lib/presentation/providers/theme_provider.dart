// lib/core/providers/theme_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:koa_app/core/theme/colors.dart';

class ThemeProvider with ChangeNotifier {
  static const String themeKey = 'theme_mode';
  static const String dyslexiaKey = 'dyslexia_font';
  static const String reduceAnimationsKey = 'reduce_animations';
  static const String disableSoundsKey = 'disable_loud_sounds';

  bool _isDarkMode = false;
  bool _isDyslexicFont = false;
  bool _reduceAnimations = false;
  bool _disableLoudSounds = true;

  bool get isDarkMode => _isDarkMode;
  bool get isDyslexicFont => _isDyslexicFont;
  bool get reduceAnimations => _reduceAnimations;
  bool get disableLoudSounds => _disableLoudSounds;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(themeKey) ?? false;
    _isDyslexicFont = prefs.getBool(dyslexiaKey) ?? false;
    _reduceAnimations = prefs.getBool(reduceAnimationsKey) ?? false;
    _disableLoudSounds = prefs.getBool(disableSoundsKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, value);
  }

  Future<void> toggleDyslexicFont(bool value) async {
    _isDyslexicFont = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dyslexiaKey, value);
  }

  Future<void> toggleReduceAnimations(bool value) async {
    _reduceAnimations = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reduceAnimationsKey, value);
  }

  Future<void> toggleDisableLoudSounds(bool value) async {
    _disableLoudSounds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(disableSoundsKey, value);
  }

  ThemeData get currentTheme {
    final baseTheme = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

    if (_isDyslexicFont) {
      return baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'OpenDyslexic'),
      );
    }

    return baseTheme;
  }
}
