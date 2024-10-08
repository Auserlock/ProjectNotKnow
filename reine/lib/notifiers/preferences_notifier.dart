import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'preferences.dart';

class PreferencesNotifier {
  late SharedPreferences sharedPreferences;
  var _themeMode = ThemeMode.system;
  var _backgroundMode = BackgroundMode.defaultMode;
  var _backgroundColor = Colors.white;
  var _backgroundImage = '';
  var _backgroundImageFit = BoxFit.cover;
  var _backgroundImageOpacity = 0.6;
  var _backgroundImageBlurriness = 10.0;

  ThemeMode get currentTheme => _themeMode;
  BackgroundMode get currentBackgroundMode => _backgroundMode;
  Color get currentBackgroundColor => _backgroundColor;
  String get currentBackgroundImage => _backgroundImage;
  BoxFit get currentBackgroundImageFit => _backgroundImageFit;
  double get currentBackgroundImageOpacity => _backgroundImageOpacity;
  double get currentBackgroundImageBlurriness => _backgroundImageBlurriness;


  Future<void> loadPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var theme = sharedPreferences.getString('theme');
    if (theme != null) {
      _themeMode = ThemeMode.values
          .firstWhere((element) => element.toString().split('.').last == theme);
    }
    var backgroundMode = sharedPreferences.getString('backgroundMode');
    if (backgroundMode != null) {
      _backgroundMode = BackgroundMode.values.firstWhere(
          (element) => element.toString().split('.').last == backgroundMode);
    }
    var backgroundColor = sharedPreferences.getInt('backgroundColor');
    if (backgroundColor != null) {
      _backgroundColor = Color(backgroundColor);
    }
    var backgroundImage = sharedPreferences.getString('backgroundImage');
    if (backgroundImage != null) {
      _backgroundImage = backgroundImage;
    }
    var backgroundImageFit = sharedPreferences.getString('backgroundImageFit');
    if (backgroundImageFit != null) {
      _backgroundImageFit = BoxFit.values
          .firstWhere((element) => element.toString().split('.').last == backgroundImageFit);
    }
    var backgroundImageOpacity =
        sharedPreferences.getDouble('backgroundImageOpacity');
    if (backgroundImageOpacity != null) {
      _backgroundImageOpacity = backgroundImageOpacity;
    }
    var backgroundImageBlurriness =
        sharedPreferences.getDouble('backgroundImageBlurriness');
    if (backgroundImageBlurriness != null) {
      _backgroundImageBlurriness = backgroundImageBlurriness;
    }
  }

  void setTheme(ThemeMode theme) async {
    _themeMode = theme;
    await sharedPreferences.setString(
        'theme', theme.toString().split('.').last);
  }

  void setBackgroundMode(BackgroundMode backgroundMode) async {
    _backgroundMode = backgroundMode;
    await sharedPreferences.setString(
        'backgroundMode', backgroundMode.toString().split('.').last);
  }

  void setBackgroundColor(Color color) async {
    _backgroundColor = color;
    await sharedPreferences.setInt('backgroundColor', color.value);
  }

  Future<void> setBackgroundImage(FilePickerResult image) async {
    var appCacheDir = await getApplicationCacheDirectory();
    var originFile = File(image.files.single.path!);
    var bytes = await originFile.readAsBytes();
    var hashCode = sha256.convert(bytes).toString();
    var imageFile = File('${appCacheDir.path}/$hashCode.bg');
    await originFile.copy(imageFile.path);
    await sharedPreferences.setString('backgroundImage', imageFile.path);
    _backgroundImage = imageFile.path;
  }

  void setBackgroundImageFit(BoxFit fit) async {
    _backgroundImageFit = fit;
    await sharedPreferences.setString('backgroundImageFit', fit.toString().split('.').last);
  }

  void setBackgroundImageOpacity(double opacity) async {
    _backgroundImageOpacity = opacity;
    await sharedPreferences.setDouble('backgroundImageOpacity', opacity);
  }

  void setBackgroundImageBlurriness(double blurriness) async {
    _backgroundImageBlurriness = blurriness;
    await sharedPreferences.setDouble('backgroundImageBlurriness', blurriness);
  }
}
