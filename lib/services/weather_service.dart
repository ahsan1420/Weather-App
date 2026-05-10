import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('API key not found in .env');
    }
    return key;
  }

  /// Fetch weather by city name
  Future<WeatherModel> fetchWeather(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) throw Exception('Please enter a city name.');

    final url = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(trimmed)}&appid=$_apiKey&units=metric',
    );

    return _executeRequest(url, trimmed);
  }

  /// Fetch weather by GPS coordinates
  Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    return _executeRequest(url, 'your location');
  }

  /// Fetch 5-day forecast
  Future<List<ForecastModel>> fetchForecast(String city) async {
    final trimmed = city.trim();
    final url = Uri.parse(
      '$_baseUrl/forecast?q=${Uri.encodeComponent(trimmed)}&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List;
        // Get one forecast per day (every 8th = 24h)
        return list
            .asMap()
            .entries
            .where((e) => e.key % 8 == 0)
            .map((e) => ForecastModel.fromJson(e.value as Map<String, dynamic>))
            .take(5)
            .toList();
      }
      throw Exception('Failed to load forecast');
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    }
  }

  Future<WeatherModel> _executeRequest(Uri url, String city) async {
    try {
      _log('Fetching: $url');
      final response = await _client.get(url).timeout(_timeout);
      return _handleResponse(response, city);
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    }
  }

  WeatherModel _handleResponse(http.Response response, String city) {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(data);
      case 401:
        throw Exception('Invalid API key.');
      case 404:
        throw Exception('City "$city" not found.');
      case 429:
        throw Exception('Too many requests. Try again later.');
      case 500:
      case 502:
      case 503:
        throw Exception('Server unavailable.');
      default:
        throw Exception('Error ${response.statusCode}');
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[WeatherService] $msg');
  }

  void dispose() => _client.close();
}
