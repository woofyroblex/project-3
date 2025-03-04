import 'dart:convert';
import 'package:dio/dio.dart';

class GeminiAIService {
  final String apiKey = "YOUR_GEMINI_API_KEY";  
  final Dio _dio = Dio();

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await _dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey",
        data: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]}),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      return "Error: $e";
    }
  }
}
