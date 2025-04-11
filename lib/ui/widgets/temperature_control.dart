import 'package:flutter/material.dart';

class TemperatureControl extends StatelessWidget {
  final double temperature;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Color textColor;

  const TemperatureControl({super.key, 
    required this.temperature,
    required this.onIncrease,
    required this.onDecrease,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Temperature: ${temperature.toStringAsFixed(1)}°C',
          style: TextStyle(fontSize: 20, color: textColor),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove, size: 30, color: textColor),
              onPressed: onDecrease,
            ),
            IconButton(
              icon: Icon(Icons.add, size: 30, color: textColor),
              onPressed: onIncrease,
            ),
          ],
        ),
      ],
    );
  }
}
