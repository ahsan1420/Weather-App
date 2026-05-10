import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';

import '../constants/app_constants.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';
import '../services/ai_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../utils/weather_theme.dart';
import '../widgets/action_buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/forecast_list.dart';
import '../widgets/search_field.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();

  WeatherModel? _weather;
  List<ForecastModel> _forecasts = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _customBackground;

  // ============ Weather Logic ============

  Future<void> _getWeatherByCity() async {
    FocusScope.of(context).unfocus();

    final city = _cityController.text.trim();

    if (city.isEmpty) {
      setState(() => _errorMessage = 'Please enter a city name');
      return;
    }

    await _loadWeather(() => _weatherService.fetchWeather(city), city);
  }

  Future<void> _getWeatherByLocation() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();

      await _loadWeather(
        () => _weatherService.fetchWeatherByCoords(
          position.latitude,
          position.longitude,
        ),
        null,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeather(
    Future<WeatherModel> Function() fetcher,
    String? cityForForecast,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
      _forecasts = [];
    });

    try {
      final weather = await fetcher();

      if (!mounted) return;

      List<ForecastModel> forecasts = [];

      try {
        forecasts = await _weatherService.fetchForecast(weather.city);
      } catch (_) {
        // Forecast is optional, so silently ignore forecast errors.
      }

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _forecasts = forecasts;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============ AI Sky Analysis ============

  Future<void> _analyzeSkyPhoto() async {
    final source = await _showImageSourceDialog();

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked == null) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final currentWeather = _weather;

      final result = await _aiService.analyzeSkyImage(
        File(picked.path),
        temperature: currentWeather?.temp,
        humidity: currentWeather?.humidity,
        windSpeed: currentWeather?.windSpeed,
        condition: currentWeather?.description,
        city: currentWeather?.city,
      );

      if (!mounted) return;

      Navigator.pop(context);

      _showResultDialog(
        title: '🤖 AI Sky Analysis',
        imagePath: picked.path,
        content: result,
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showSnack('Analysis failed: ${e.toString()}');
    }
  }

  // ============ Custom Background ============

  Future<void> _setCustomBackground() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => _customBackground = File(picked.path));

    _showSnack('Background updated! ✨');
  }

  void _resetBackground() {
    setState(() => _customBackground = null);

    _showSnack('Background reset');
  }

  // ============ Photo Location Weather ============

  Future<void> _getWeatherFromPhotoLocation() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final exif = await Exif.fromPath(picked.path);
      final coords = await exif.getLatLong();
      await exif.close();

      if (!mounted) return;

      Navigator.pop(context);
      if (coords == null) {
        _showSnack('Weather loaded from current location📍');

        final position = await _locationService.getCurrentPosition();

        await _loadWeather(
          () => _weatherService.fetchWeatherByCoords(
            position.latitude,
            position.longitude,
          ),
          null,
        );

        return;
      }

      _showSnack('Weather loaded from photo location 📸');
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showSnack('Could not read photo location');
    }
  }

  // ============ Helpers ============

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Source'),
        content: const Text('Where to get the photo?'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  void _showResultDialog({
    required String title,
    required String imagePath,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearSearch() {
    _cityController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _cityController.dispose();
    _weatherService.dispose();
    super.dispose();
  }

  // ============ UI ============

  @override
  Widget build(BuildContext context) {
    final weather = _weather;

    final gradientColors = weather != null
        ? WeatherTheme.getGradient(weather.weatherId)
        : AppConstants.defaultGradient;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🌤️ Weather App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_customBackground != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset background',
              onPressed: _resetBackground,
            ),
        ],
      ),
      body: AnimatedContainer(
        duration: AppConstants.backgroundAnimationDuration,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _customBackground != null
              ? DecorationImage(
                  image: FileImage(_customBackground!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: _customBackground == null
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                )
              : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    SearchField(
                      controller: _cityController,
                      onSubmit: _getWeatherByCity,
                      onClear: _clearSearch,
                      onLocationTap: _getWeatherByLocation,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    if (_errorMessage != null) _buildErrorMessage(),
                    AnimatedSwitcher(
                      duration: AppConstants.switcherAnimationDuration,
                      child: weather != null
                          ? Column(
                              children: [
                                WeatherCard(weather: weather),
                                const SizedBox(height: 24),
                                ForecastList(forecasts: _forecasts),
                              ],
                            )
                          : !_isLoading && _errorMessage == null
                              ? const EmptyState()
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ActionButtons(
                  onAnalyzeSky: _analyzeSkyPhoto,
                  onSetBackground: _setCustomBackground,
                  onPhotoLocation: _getWeatherFromPhotoLocation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _errorMessage!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
