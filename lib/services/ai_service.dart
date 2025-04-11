class AIService {
  // 🔥 Get hydration advice based on daily water intake
  Future<String> getHydrationTip(double waterIntake) async {
    if (waterIntake < 2.0) {
      return "You're not drinking enough water! Stay hydrated. 💧";
    } else if (waterIntake >= 2.0 && waterIntake < 3.5) {
      return "You're doing well! Keep it up. 👍";
    } else {
      return "Great job! You're fully hydrated. 🎉";
    }
  }

  // 📊 Predict ideal water intake based on temperature
  Future<double> predictWaterIntake(double temperature) async {
    if (temperature < 15.0) {
      return 2.0; // Less water needed in cold weather
    } else if (temperature < 30.0) {
      return 2.5;
    } else {
      return 3.5; // More water needed in hot weather
    }
  }
}
