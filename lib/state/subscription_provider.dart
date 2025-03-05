// subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService;
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider(this._subscriptionService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> canUseService(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      bool hasActive = await _subscriptionService.hasActiveSubscription(userId);
      if (hasActive) return true;

      bool hasUsed = await _subscriptionService.hasUsedFreeService(userId);
      return !hasUsed;
    } catch (e) {
      _error = 'Error checking service access: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryUseService(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _subscriptionService.useService(userId);
      return true;
    } catch (e) {
      _error = 'Failed to use service: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseSubscription(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool success = await _subscriptionService.chargeForService(userId);
      if (success) {
        await _subscriptionService.useService(userId);
      }
      return success;
    } catch (e) {
      _error = 'Failed to purchase subscription: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
