import 'dart:convert';
import 'package:dio/dio.dart';

class VertexAIService {
  final String apiKey = "YOUR_VERTEX_AI_KEY";
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> analyzeImage(String imageUrl) async {
    try {
      final response = await _dio.post(
        "https://vision.googleapis.com/v1/images:annotate?key=$apiKey",
        data: jsonEncode({
          "requests": [
            {
              "image": {
                "source": {"imageUri": imageUrl}
              },
              "features": [
                {"type": "LABEL_DETECTION"}
              ]
            }
          ]
        }),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data;
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
