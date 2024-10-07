import 'package:flutter/material.dart';
import '../views/views.dart';
import 'page_notifier.dart';
import 'theme_notifier.dart';

class GlobalNotifiers extends ChangeNotifier {
  final _themeNotifier = ThemeNotifier();
  final _pageNotifier = PageNotifier();

  ThemeMode get currentTheme => _themeNotifier.currentTheme;
  String get currentPageName => _pageNotifier.currentPageName;
  CurrentView get currentPage => _pageNotifier.currentPage;

  void setTheme(ThemeMode theme) async {
    _themeNotifier.setTheme(theme);
    notifyListeners();
  }

  void setCurrentPage(CurrentView page) async {
    _pageNotifier.setCurrentPage(page);
    notifyListeners();
  }
}
