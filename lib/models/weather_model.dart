class WeatherModel {
  final double temperature;
  final String condition;

  WeatherModel({required this.temperature, required this.condition});

  /// 🌦️ **Convert JSON to WeatherModel**
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}
