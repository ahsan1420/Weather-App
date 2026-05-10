class ForecastModel {
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final int weatherId;
  final String description;

  const ForecastModel({
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.weatherId,
    required this.description,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as int?) ?? 0) * 1000,
      ),
      temp: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['main']?['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['main']?['temp_max'] as num?)?.toDouble() ?? 0.0,
      weatherId: json['weather']?[0]?['id'] as int? ?? 800,
      description: json['weather']?[0]?['description'] as String? ?? '',
    );
  }

  String get icon {
    if (weatherId >= 200 && weatherId < 300) return '⛈';
    if (weatherId >= 300 && weatherId < 400) return '🌦';
    if (weatherId >= 500 && weatherId < 600) return '🌧';
    if (weatherId >= 600 && weatherId < 700) return '❄️';
    if (weatherId >= 700 && weatherId < 800) return '🌫';
    if (weatherId == 800) return '☀️';
    if (weatherId >= 801 && weatherId <= 802) return '⛅';
    if (weatherId >= 803) return '☁️';
    return '🌡';
  }

  String get tempString => '${temp.round()}°';
}
