// import 'package:flutter/material.dart';
// import '../models/water_model.dart';

// class WaterProvider with ChangeNotifier {
//   int _currentIntake = 0; // Stores current daily water intake in ml
//   List<WaterLog> _waterLogs = []; // Stores historical water logs

//   int get currentIntake => _currentIntake;
//   List<WaterLog> get waterLogs => _waterLogs;

//   // 🥤 Add water intake
//   void addWater(int amount) {
//     _currentIntake += amount;
//     _waterLogs.add(WaterLog(amount: amount, timestamp: DateTime.now()));
//     notifyListeners(); // Notifies UI to update
//   }

//   // 🔄 Reset daily water intake (called at midnight)
//   void resetDailyIntake() {
//     _currentIntake = 0;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_model.dart';

class WaterProvider with ChangeNotifier {
  int _currentIntake = 0; // Stores current daily water intake in ml
  final List<WaterLog> _waterLogs = []; // Stores historical water logs
  bool _isUserAdaptationEnabled = false; // New Toggle State
  double _recommendedTemperature = 25.0; // Default temperature

  int get currentIntake => _currentIntake;
  List<WaterLog> get waterLogs => _waterLogs;
  bool get isUserAdaptationEnabled => _isUserAdaptationEnabled;
  double get recommendedTemperature => _recommendedTemperature;

  WaterProvider() {
    _loadUserAdaptationState(); // Load the toggle state on init
  }

  // 🥤 Add water intake
  void addWater(int amount) {
    _currentIntake += amount;
    _waterLogs.add(WaterLog(amount: amount, timestamp: DateTime.now()));
    notifyListeners(); // Notifies UI to update
  }

  // 🔄 Reset daily water intake (called at midnight)
  void resetDailyIntake() {
    _currentIntake = 0;
    notifyListeners();
  }

  // 🔹 Load User Adaptation State from Local Storage
  Future<void> _loadUserAdaptationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isUserAdaptationEnabled = prefs.getBool('user_adaptation') ?? false;
    _updateRecommendedTemperature(); // Adjust temperature based on state
    notifyListeners();
  }

  // 🔹 Save User Adaptation State
  Future<void> saveUserAdaptationState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_adaptation', value);
    _isUserAdaptationEnabled = value;
    _updateRecommendedTemperature(); // Adjust temperature
    notifyListeners();
  }

  // 🌡️ Adjust recommended temperature based on User Adaptation
  void _updateRecommendedTemperature() {
    if (_isUserAdaptationEnabled) {
      _recommendedTemperature = _calculatePersonalizedTemperature();
    } else {
      _recommendedTemperature = 25.0; // Default temperature
    }
  }

  // 🔥 Calculate personalized temperature (Mock Logic for Now)
  double _calculatePersonalizedTemperature() {
    // Example: Adjust temperature based on past usage
    if (_currentIntake > 2000) {
      return 20.0; // Cooler temp for high hydration
    } else if (_currentIntake < 1000) {
      return 28.0; // Warmer temp for lower hydration
    }
    return 25.0; // Default
  }
}
