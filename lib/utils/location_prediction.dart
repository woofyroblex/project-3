import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPrediction {
  static double compareLocations(GeoPoint location1, GeoPoint location2) {
    try {
      // Calculate distance between points
      double lat1 = location1.latitude;
      double lon1 = location1.longitude;
      double lat2 = location2.latitude;
      double lon2 = location2.longitude;

      // Simple distance-based similarity (can be enhanced with more complex algorithms)
      double distance = _calculateDistance(lat1, lon1, lat2, lon2);
      return _normalizeDistance(distance);
    } catch (e) {
      return 0.0;
    }
  }

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Implement Haversine formula or similar for distance calculation
    // For now, using simple absolute difference
    double latDiff = (lat1 - lat2).abs();
    double lonDiff = (lon1 - lon2).abs();
    return (latDiff + lonDiff) / 2;
  }

  static double _normalizeDistance(double distance) {
    // Convert distance to similarity score (0-1)
    // Smaller distances = higher similarity
    return (1 / (1 + distance)).clamp(0.0, 1.0);
  }
}
