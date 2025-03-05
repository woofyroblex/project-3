import 'package:flutter/foundation.dart';

class LocationPredictionService {
  static double compareLocations({
    required String? expectedLocation,
    required String? foundLocation,
  }) {
    try {
      if (expectedLocation == null || foundLocation == null) {
        return 0.0;
      }

      // Convert to lowercase for case-insensitive comparison
      final expected = expectedLocation.toLowerCase();
      final found = foundLocation.toLowerCase();

      // Exact match
      if (expected == found) return 1.0;

      // Contains check
      if (expected.contains(found) || found.contains(expected)) {
        return 0.7;
      }

      // Basic word matching
      final expectedWords = expected.split(' ');
      final foundWords = found.split(' ');
      int matchingWords = 0;

      for (final word in expectedWords) {
        if (foundWords.contains(word)) matchingWords++;
      }

      if (matchingWords > 0) {
        return (matchingWords / expectedWords.length).clamp(0.0, 0.5);
      }

      return 0.0;
    } catch (e) {
      debugPrint('Error comparing locations: $e');
      return 0.0;
    }
  }
}
