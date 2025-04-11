import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = '427d14c5c8a42c65d07c06e97888396a';

  /// 🌦️ **Fetch Weather by Latitude & Longitude**
  Future<WeatherModel?> getWeather(double latitude, double longitude) async {
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        print('❌ Failed to fetch weather: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching weather: $e');
      return null;
    }
  }
}
