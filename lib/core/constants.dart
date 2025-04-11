import 'package:flutter/material.dart';

// 🔥 Temperature Limits
const double MIN_TEMPERATURE = 10.0;
const double MAX_TEMPERATURE = 50.0;
const double DEFAULT_TEMPERATURE = 25.0;

// 📌 Firebase Collection Names
const String TEMPERATURE_COLLECTION = "temperature_logs";
const String HYDRATION_COLLECTION = "hydration_logs";

// 🎨 UI Colors (Light & Dark Mode Support)
const Color LIGHT_MODE_BG = Color(0xFFF8F8F8);
const Color DARK_MODE_BG = Color(0xFF121212);
const Color PRIMARY_COLOR = Colors.blue;
const Color ACCENT_COLOR = Colors.orange;
