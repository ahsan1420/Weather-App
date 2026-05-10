import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/weather_model.dart';
import 'weather_info_item.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(weather.city),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weather.icon, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 12),
          Text(
            weather.fullLocation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            weather.tempString,
            style: const TextStyle(
              fontSize: 56,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            weather.capitalizedDescription,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherInfoItem(
                icon: Icons.thermostat,
                title: 'Feels Like',
                value: weather.feelsLikeString,
              ),
              WeatherInfoItem(
                icon: Icons.water_drop,
                title: 'Humidity',
                value: weather.humidityString,
              ),
              WeatherInfoItem(
                icon: Icons.air,
                title: 'Wind',
                value: weather.windSpeedString,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
