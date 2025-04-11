import 'package:flutter/material.dart';
import '../core/theme.dart'; // Import your theme file

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = AppTheme.lightTheme; // Default: Light Mode

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == AppTheme.darkTheme;

  void toggleTheme() {
    _themeData = isDarkMode ? AppTheme.lightTheme : AppTheme.darkTheme;
    notifyListeners(); // Notify UI to rebuild
  }
}
