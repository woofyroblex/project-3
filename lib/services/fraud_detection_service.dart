import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/location_prediction.dart';

class FraudDetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Risk score constants
  static const double _HIGH_RISK_THRESHOLD = 0.8;
  static const int _HIGH_REPORTS_THRESHOLD = 10;

  Future<bool> analyzeTransaction(Map<String, dynamic> transaction) async {
    try {
      final score = await _calculateRiskScore(transaction);
      debugPrint('Transaction risk score: $score');
      return score > _HIGH_RISK_THRESHOLD;
    } catch (e) {
      debugPrint('Error analyzing transaction: $e');
      return false;
    }
  }

  Future<double> _calculateRiskScore(Map<String, dynamic> transaction) async {
    double score = 0.0;

    // Get user data for analysis
    final UserModel? user = await _getUserData(transaction['userId']);
    if (user == null) return _HIGH_RISK_THRESHOLD;

    // Check user history
    score += _checkUserHistory(user);

    // Check transaction patterns
    score += await _checkTransactionPatterns(user.userId);

    // Check location patterns
    score += _checkLocationPatterns(transaction);

    return score / 3; // Normalize the score
  }

  double _checkUserHistory(UserModel user) {
    double score = 0.0;

    // Check reputation score
    if (user.reputationScore < 50) score += 0.3;

    // Check verification status
    if (user.verificationStatus == VerificationStatus.unverified) {
      score += 0.2;
    }

    // Check report frequency
    if (_isReportFrequencyHigh(user)) {
      score += 0.3;
    }

    return score;
  }

  bool _isReportFrequencyHigh(UserModel user) {
    return user.reportCount > _HIGH_REPORTS_THRESHOLD;
  }

  Future<double> _checkTransactionPatterns(String userId) async {
    try {
      final QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (transactions.docs.isEmpty) return 0.0;

      // Analyze transaction patterns
      double unusualPatternScore = 0.0;
      double previousAmount = 0.0;

      for (var doc in transactions.docs) {
        final transaction = doc.data() as Map<String, dynamic>;
        final double amount = transaction['amount'] ?? 0.0;

        if (previousAmount > 0 && amount > previousAmount * 3) {
          unusualPatternScore += 0.2;
        }

        previousAmount = amount;
      }

      return unusualPatternScore.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('Error checking transaction patterns: $e');
      return 0.0;
    }
  }

  double _checkLocationPatterns(Map<String, dynamic> transaction) {
    try {
      final GeoPoint? reportedLocation = transaction['location'] as GeoPoint?;
      final GeoPoint? userLocation = transaction['userLocation'] as GeoPoint?;

      if (reportedLocation == null || userLocation == null) {
        return 0.5; // Medium risk for missing location data
      }

      // Compare locations using prediction service
      final locationScore = LocationPrediction.compareLocations(
        reportedLocation,
        userLocation,
      );

      // Inverse the score since higher similarity means lower risk
      return 1.0 - locationScore;
    } catch (e) {
      debugPrint('Error checking location patterns: $e');
      return 0.5; // Default to medium risk on error
    }
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) return null;

      return UserModel.fromFirestore(docSnapshot);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }
}

// Example of how to create a transaction with GeoPoint locations
Map<String, dynamic> createTransaction({
  required String userId,
  required GeoPoint reportedLocation,
  required GeoPoint userLocation,
  // other parameters...
}) {
  return {
    'userId': userId,
    'location': reportedLocation,
    'userLocation': userLocation,
    'timestamp': FieldValue.serverTimestamp(),
    // other transaction data...
  };
}
