// 📌 Format temperature with one decimal place
String formatTemperature(double temp) {
  return "${temp.toStringAsFixed(1)}°C";
}

// 🔄 Convert Celsius to Fahrenheit
double celsiusToFahrenheit(double celsius) {
  return (celsius * 9 / 5) + 32;
}

// 🔄 Convert Fahrenheit to Celsius
double fahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}
