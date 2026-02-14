import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  GeminiService() {
    _model = GenerativeModel(
      // Using gemini-2.5-flash as requested and verified available
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>?> parseOrder(String text) async {
    // Check if the key is missing or is the placeholder
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      debugPrint('Error: Gemini API Key not found in .env file');
      return null;
    }

    final prompt = '''
You are an inventory assistant. Extract the following details from the order text:
- name (String): Item name
- qty (String): Quantity (e.g., "50 kg")
- price (String): Price (e.g., "₹4,500")

Text: "$text"

Return ONLY a valid JSON object with this exact structure:
{
  "name": "item name",
  "qty": "quantity",
  "price": "price"
}

Do not include markdown formatting, explanations, or code blocks.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        debugPrint('Gemini returned empty response');
        return null;
      }

      // Clean up potential markdown and whitespace
      String cleanText = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final parsed = jsonDecode(cleanText) as Map<String, dynamic>;
      
      // Validate required fields
      if (!parsed.containsKey('name') || 
          !parsed.containsKey('qty') || 
          !parsed.containsKey('price')) {
        debugPrint('Gemini response missing required fields');
        return null;
      }
      
      return parsed;
    } catch (e) {
      debugPrint('Gemini Error: $e');
      return null;
    }
  }
}