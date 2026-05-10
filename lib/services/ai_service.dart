import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];

    if (key == null || key.trim().isEmpty) {
      throw Exception('Gemini API key not found. Please check your .env file.');
    }

    return key.trim();
  }

  Future<String> analyzeSkyImage(
    File image, {
    double? temperature,
    int? humidity,
    double? windSpeed,
    String? condition,
    String? city,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final imageBytes = await image.readAsBytes();

      final prompt = TextPart('''
Analyze this sky/weather photo and current weather data.

Current weather data:
- City: ${city ?? 'Unknown'}
- Temperature: ${temperature ?? 'Unknown'} °C
- Humidity: ${humidity ?? 'Unknown'}%
- Wind Speed: ${windSpeed ?? 'Unknown'} m/s
- Weather Condition: ${condition ?? 'Unknown'}

Give a short friendly analysis:

🌤️ Sky Condition:
🌧️ Chance of Rain: Low / Medium / High with percentage estimate
💨 Wind: Calm / Light / Moderate / Strong
🌡️ Feel:
📝 Advice:

Rules:
- Estimate rain chance using the photo, humidity, clouds, and weather condition.
- Wind should be based mainly on the wind speed value.
- Keep it short and friendly.
- Use emojis.
''');

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([
          prompt,
          imagePart,
        ]),
      ]);

      return response.text ?? 'Could not analyze image.';
    } catch (e) {
      return 'DEBUG ERROR:\n${e.toString()}';
    }
  }
}
