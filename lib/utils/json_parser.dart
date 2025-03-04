//lib/utils/json_parser.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Custom function to decode JSON with a defined return type
List<dynamic> jsonParser(String jsonString) {
  return json.decode(jsonString) as List<dynamic>;
}

/// Parses JSON in an isolate using `compute`
Future<List<dynamic>> parseJson(String jsonString) async {
  return compute(jsonParser, jsonString);
}
