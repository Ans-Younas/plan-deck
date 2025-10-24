import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  late Box<String> _themeBox;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _initTheme();
  }

  Future<void> _initTheme() async {
    _themeBox = await Hive.openBox<String>('settings');
    final savedTheme = _themeBox.get('themeMode');
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$savedTheme',
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _themeBox.put('themeMode', _themeMode.name);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _themeBox.put('themeMode', _themeMode.name);
    notifyListeners();
  }
}
