import 'package:flutter/material.dart';

class ThemeNotifier {
  var _themeMode = ThemeMode.system;

  ThemeMode get currentTheme => _themeMode;

  void setTheme(ThemeMode theme) async {
    _themeMode = theme;
  }
}
