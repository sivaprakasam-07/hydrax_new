import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/temperature_control.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _selectedTemperature = 25.0;

  void _increaseTemperature() {
    setState(() {
      if (_selectedTemperature < 50) _selectedTemperature += 1;
    });
  }

  void _decreaseTemperature() {
    setState(() {
      if (_selectedTemperature > 10) _selectedTemperature -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary, // Ensures visibility in both themes
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adjust Temperature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // Fixes visibility issue
              ),
            ),
            SizedBox(height: 10),
            // Temperature Display Fix
            Text(
              'Temperature: ${_selectedTemperature.toStringAsFixed(1)}°C',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // Ensures visibility
              ),
            ),
            SizedBox(height: 10),
            TemperatureControl(
              temperature: _selectedTemperature,
              onIncrease: _increaseTemperature,
              onDecrease: _decreaseTemperature,
              textColor: theme.colorScheme.onSurface, // Pass adaptive color
            ),
            SizedBox(height: 20),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.5)), // Adapts to theme
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, color: isDarkMode ? Colors.grey[400] : Colors.orange),
                Switch(
                  value: themeProvider.isDarkMode,
                  activeColor: theme.colorScheme.primary,
                  inactiveTrackColor: isDarkMode ? Colors.grey[700] : Colors.grey[500], // Fix contrast
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                Icon(Icons.nightlight_round, color: isDarkMode ? Colors.yellow[300] : Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}