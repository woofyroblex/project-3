//lib/services/reputation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Logger instance for better logging
final logger = Logger();

/// ReputationService to handle all reputation-related backend logic
class ReputationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch the reputation score of a specific user from Firestore
  Future<int> getReputationScore(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot['reputationScore'] ?? 0;
      } else {
        throw Exception("User not found.");
      }
    } catch (e) {
      logger.e("Error fetching reputation: $e");
      rethrow;
    }
  }

  /// Increase the user's reputation score in Firestore
  Future<void> increaseReputation(String userId, int points) async {
    await _updateReputation(userId, points);
  }

  /// Decrease the user's reputation score in Firestore
  Future<void> decreaseReputation(String userId, int points) async {
    await _updateReputation(userId, -points);
  }

  /// Update the user's reputation score in Firestore
  Future<void> _updateReputation(String userId, int points) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          throw Exception("User not found.");
        }

        int currentScore = snapshot['reputationScore'] ?? 0;
        int updatedScore = currentScore + points;

        // Prevent reputation score from going below zero
        if (updatedScore < 0) {
          updatedScore = 0;
        }

        transaction.update(userDoc, {'reputationScore': updatedScore});
      });
    } catch (e) {
      logger.e("Error updating reputation: $e");
      rethrow;
    }
  }

  /// Reset reputation score to zero (can be used by Admin)
  Future<void> resetUserReputation(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'reputationScore': 0,
      });
    } catch (e) {
      logger.e("Error resetting reputation: $e");
      rethrow;
    }
  }
}

/// Provider for ReputationService instance using Riverpod
final reputationServiceProvider = Provider<ReputationService>((ref) {
  return ReputationService();
});
