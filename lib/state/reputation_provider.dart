// lib/state/reputation_provider.dart

import 'package:flutter/material.dart';
import '../services/reputation_service.dart';

class ReputationProvider with ChangeNotifier {
  final ReputationService _reputationService = ReputationService();

  int _reputationScore = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get reputationScore => _reputationScore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Reputation Score from the Server
  Future<void> fetchUserReputation(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reputationScore = await _reputationService.getReputationScore(userId);
    } catch (e) {
      _errorMessage = "Failed to fetch reputation score: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Increase Reputation on Successful Return of Item
  Future<void> increaseReputation(String userId, int points) async {
    try {
      await _reputationService.increaseReputation(userId, points);
      _reputationScore += points;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to increase reputation: $e";
      notifyListeners();
    }
  }

  // Decrease Reputation for Fraudulent Activity
  Future<void> decreaseReputation(String userId, int points) async {
    try {
      await _reputationService.decreaseReputation(userId, points);
      _reputationScore -= points;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to decrease reputation: $e";
      notifyListeners();
    }
  }

  // Reset Reputation Data
  void resetReputation() {
    _reputationScore = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
