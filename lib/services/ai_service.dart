class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

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

  // 🤖 Linear Regression Temperature Prediction
  // This simulates the ML model prediction based on 75 users' temperature data
  Future<double> predictOptimalTemperature({
    required double currentTemperature,
    required double ambientTemperature,
    required double userPreference,
    required double timeOfDay, // 0-24 hours
  }) async {
    try {
      // Simulate loading and using the trained model
      // In a real implementation, you would load the .pkl file and use an ML library
      
      // Mock linear regression calculation based on the 75 users' data pattern
      // This simulates what a trained model would predict
      
      double baseTemperature = _calculateBaseTemperature(currentTemperature, ambientTemperature);
      double personalizedAdjustment = _calculatePersonalizedAdjustment(userPreference, timeOfDay);
      double averageUserPreference = _getAverageUserTemperature();
      
      // Apply linear regression formula: y = mx + b
      double predictedTemperature = (baseTemperature * 0.6) + 
                                  (personalizedAdjustment * 0.2) + 
                                  (averageUserPreference * 0.2);
      
      // Ensure temperature is within safe bounds
      return predictedTemperature.clamp(15.0, 45.0);
      
    } catch (e) {
      print('Error in temperature prediction: $e');
      return currentTemperature; // Fallback to current temperature
    }
  }

  // Calculate base temperature considering environmental factors
  double _calculateBaseTemperature(double current, double ambient) {
    if (ambient > 30) {
      return current - 3; // Cooler bottle in hot weather
    } else if (ambient < 15) {
      return current + 2; // Warmer bottle in cold weather
    }
    return current;
  }

  // Calculate personalized adjustment based on user patterns
  double _calculatePersonalizedAdjustment(double userPref, double timeOfDay) {
    // Morning (6-12): slightly warmer
    if (timeOfDay >= 6 && timeOfDay < 12) {
      return userPref + 1;
    }
    // Afternoon (12-18): cooler
    else if (timeOfDay >= 12 && timeOfDay < 18) {
      return userPref - 2;
    }
    // Evening/Night (18-6): moderate
    else {
      return userPref;
    }
  }

  // Simulated average temperature from 75 users' training data
  double _getAverageUserTemperature() {
    // This represents the average preferred temperature from the training dataset
    return 22.5; // Average of 75 users' preferred temperatures
  }

  // 🎯 Smart Temperature Calculation with Linear Regression
  Future<Map<String, dynamic>> getSmartTemperatureRecommendation({
    required double currentTemp,
    required double ambientTemp,
    required double userPreference,
  }) async {
    double timeOfDay = DateTime.now().hour.toDouble();
    
    double predictedTemp = await predictOptimalTemperature(
      currentTemperature: currentTemp,
      ambientTemperature: ambientTemp,
      userPreference: userPreference,
      timeOfDay: timeOfDay,
    );

    double averageTemp = _getAverageUserTemperature();
    
    return {
      'predictedTemperature': predictedTemp,
      'averageUserTemperature': averageTemp,
      'confidence': _calculateConfidence(currentTemp, predictedTemp),
      'reason': _getRecommendationReason(predictedTemp, averageTemp, ambientTemp),
    };
  }

  // Calculate confidence level of the prediction
  double _calculateConfidence(double current, double predicted) {
    double difference = (current - predicted).abs();
    if (difference <= 2) return 0.95;
    if (difference <= 5) return 0.85;
    if (difference <= 8) return 0.75;
    return 0.65;
  }

  // Provide explanation for the recommendation
  String _getRecommendationReason(double predicted, double average, double ambient) {
    if (predicted > average + 2) {
      return "Based on current conditions, warmer water is recommended for better hydration.";
    } else if (predicted < average - 2) {
      return "Cooler temperature suggested due to ${ambient > 25 ? 'hot weather' : 'your usage pattern'}.";
    } else {
      return "Optimal temperature based on 75 users' preferences and current conditions.";
    }
  }
}
