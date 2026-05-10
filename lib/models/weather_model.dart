class WeatherModel {
  final String city;
  final String country;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final int weatherId;

  const WeatherModel({
    required this.city,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.weatherId,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] as String? ?? 'Unknown',
      country: json['sys']?['country'] as String? ?? '',
      temp: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      condition: json['weather']?[0]?['main'] as String? ?? 'Unknown',
      description: json['weather']?[0]?['description'] as String? ?? '',
      weatherId: (json['weather']?[0]?['id'] as num?)?.toInt() ?? 800,
    );
  }

  String get icon {
    if (weatherId >= 200 && weatherId < 300) return '⛈';
    if (weatherId >= 300 && weatherId < 400) return '🌦';
    if (weatherId >= 500 && weatherId < 600) return '🌧';
    if (weatherId >= 600 && weatherId < 700) return '❄️';
    if (weatherId >= 700 && weatherId < 800) return '🌫';
    if (weatherId == 800) return '☀️';
    if (weatherId == 801) return '🌤';
    if (weatherId == 802) return '⛅';
    if (weatherId >= 803) return '☁️';

    return '🌡';
  }

  String get tempString => '${temp.toStringAsFixed(1)}°C';

  String get feelsLikeString => '${feelsLike.toStringAsFixed(1)}°C';

  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';

  String get humidityString => '$humidity%';

  String get fullLocation {
    if (country.isEmpty) return city;
    return '$city, $country';
  }

  String get capitalizedDescription {
    if (description.isEmpty) return '';
    return description[0].toUpperCase() + description.substring(1);
  }

  // Optional helper for AI prompt
  String get aiWeatherSummary {
    return '''
City: $fullLocation
Temperature: ${temp.toStringAsFixed(1)}°C
Feels Like: ${feelsLike.toStringAsFixed(1)}°C
Humidity: $humidity%
Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s
Condition: $condition
Description: $capitalizedDescription
''';
  }
}
