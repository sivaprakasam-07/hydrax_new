class WaterLog {
  final int amount; // Water intake in milliliters (ml)
  final DateTime timestamp; // Time when water was consumed

  WaterLog({required this.amount, required this.timestamp});

  // Convert to JSON (for Firebase)
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create WaterLog object from JSON (for Firebase retrieval)
  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      amount: json['amount'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class TemperatureLog {
  final int temperature; // Temperature in °C
  final DateTime timestamp; // Time of measurement

  TemperatureLog({required this.temperature, required this.timestamp});

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory TemperatureLog.fromJson(Map<String, dynamic> json) {
    return TemperatureLog(
      temperature: json['temperature'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
