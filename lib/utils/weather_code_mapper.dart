import 'package:flutter/material.dart';

class WeatherConditionInfo {
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}

class WeatherCodeMapper {
  static WeatherConditionInfo getInfo(int code) {
    switch (code) {
      case 0:
        return WeatherConditionInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_sunny_rounded,
          gradientColors: [const Color(0xFF1E88E5), const Color(0xFF64B5F6)],
        );
      case 1:
        return WeatherConditionInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_sunny_outlined,
          gradientColors: [const Color(0xFF1976D2), const Color(0xFF90CAF9)],
        );
      case 2:
        return WeatherConditionInfo(
          description: 'Sebagian Berawan',
          icon: Icons.cloud_queue_rounded,
          gradientColors: [const Color(0xFF1565C0), const Color(0xFF64B5F6)],
        );
      case 3:
        return WeatherConditionInfo(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          gradientColors: [const Color(0xFF37474F), const Color(0xFF78909C)],
        );
      case 45:
      case 48:
        return WeatherConditionInfo(
          description: 'Berkabut',
          icon: Icons.blur_on_rounded,
          gradientColors: [const Color(0xFF455A64), const Color(0xFF90A4AE)],
        );
      case 51:
      case 53:
      case 55:
        return WeatherConditionInfo(
          description: 'Gerimis Ringan',
          icon: Icons.grain_rounded,
          gradientColors: [const Color(0xFF0277BD), const Color(0xFF4FC3F7)],
        );
      case 61:
      case 63:
        return WeatherConditionInfo(
          description: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          gradientColors: [const Color(0xFF0D47A1), const Color(0xFF42A5F5)],
        );
      case 65:
        return WeatherConditionInfo(
          description: 'Hujan Lebat',
          icon: Icons.beach_access_rounded,
          gradientColors: [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return WeatherConditionInfo(
          description: 'Salju',
          icon: Icons.ac_unit_rounded,
          gradientColors: [const Color(0xFF455A64), const Color(0xFFB0BEC5)],
        );
      case 80:
      case 81:
      case 82:
        return WeatherConditionInfo(
          description: 'Hujan Guyur / Deras',
          icon: Icons.thunderstorm_outlined,
          gradientColors: [const Color(0xFF1A237E), const Color(0xFF283593)],
        );
      case 95:
      case 96:
      case 99:
        return WeatherConditionInfo(
          description: 'Badai Petir',
          icon: Icons.flash_on_rounded,
          gradientColors: [const Color(0xFF212121), const Color(0xFF455A64)],
        );
      default:
        return WeatherConditionInfo(
          description: 'Berawan',
          icon: Icons.cloud_outlined,
          gradientColors: [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
        );
    }
  }
}
