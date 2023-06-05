import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices{
  final _box = GetStorage();
  final _key = 'isThemeMode';
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.light : ThemeMode. dark;
  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);
  void switchTheme() {
    // Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode. dark : ThemeMode.light);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}