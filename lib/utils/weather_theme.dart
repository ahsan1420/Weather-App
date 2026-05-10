import 'package:flutter/material.dart';

class WeatherTheme {
  static List<Color> getGradient(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) {
      return [const Color(0xFF37474F), const Color(0xFF78909C)];
    }
    if (weatherId >= 300 && weatherId < 400) {
      return [const Color(0xFF4FC3F7), const Color(0xFF81D4FA)];
    }
    if (weatherId >= 500 && weatherId < 600) {
      return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
    if (weatherId >= 600 && weatherId < 700) {
      return [const Color(0xFF455A64), const Color(0xFFB0BEC5)];
    }
    if (weatherId >= 700 && weatherId < 800) {
      return [const Color(0xFF9E9E9E), const Color(0xFFCFD8DC)];
    }
    if (weatherId == 800) {
      return [const Color(0xFFFF8F00), const Color(0xFF1E88E5)];
    }
    if (weatherId > 800) {
      return [const Color(0xFF1E88E5), const Color(0xFF6EC6F5)];
    }
    return [const Color(0xFF1E88E5), const Color(0xFF6EC6F5)];
  }
}
