import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../views/views.dart';
import 'page_notifier.dart';
import 'preferences_notifier.dart';
import 'preferences.dart';

class GlobalNotifiers extends ChangeNotifier {
  final _preferencesNotifier = PreferencesNotifier();
  final _pageNotifier = PageNotifier();

  ThemeMode get currentTheme => _preferencesNotifier.currentTheme;
  String get currentPageName => _pageNotifier.currentPageName;
  CurrentView get currentPage => _pageNotifier.currentPage;
  BackgroundMode get currentBackgroundMode =>
      _preferencesNotifier.currentBackgroundMode;
  Color get currentBackgroundColor =>
      _preferencesNotifier.currentBackgroundColor;
  ImageProvider get currentBackgroundImage {
    var file = File(_preferencesNotifier.currentBackgroundImage);
    if (!file.existsSync()) {
      return const AssetImage('assets/images/defaultbg.png');
    }
    return Image.file(
      File(_preferencesNotifier.currentBackgroundImage),
    ).image;
  }

  BoxFit get currentBackgroundImageFit =>
      _preferencesNotifier.currentBackgroundImageFit;
  double get currentBackgroundImageOpacity =>
      _preferencesNotifier.currentBackgroundImageOpacity;
  double get currentBackgroundImageBlurriness =>
      _preferencesNotifier.currentBackgroundImageBlurriness;

  void initApp() async {
    await _preferencesNotifier.loadPreferences();
    notifyListeners();
  }

  void setTheme(ThemeMode theme) async {
    _preferencesNotifier.setTheme(theme);
    notifyListeners();
  }

  void setCurrentPage(CurrentView page) async {
    _pageNotifier.setCurrentPage(page);
    notifyListeners();
  }

  void setBackgroundMode(BackgroundMode backgroundMode) async {
    _preferencesNotifier.setBackgroundMode(backgroundMode);
    notifyListeners();
  }

  void setBackgroundColor(Color color) async {
    _preferencesNotifier.setBackgroundColor(color);
    notifyListeners();
  }

  void setBackgroundImage(FilePickerResult image) async {
    await _preferencesNotifier.setBackgroundImage(image);
    notifyListeners();
  }

  void setBackgroundImageFit(BoxFit fit) async {
    _preferencesNotifier.setBackgroundImageFit(fit);
    notifyListeners();
  }

  void setBackgroundImageOpacity(double opacity) async {
    _preferencesNotifier.setBackgroundImageOpacity(opacity);
    notifyListeners();
  }

  void setBackgroundImageBlurriness(double blurriness) async {
    _preferencesNotifier.setBackgroundImageBlurriness(blurriness);
    notifyListeners();
  }
}
