// lib/state/security_provider.dart

import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService = SecurityService();

  bool _isUserVerified = false;
  bool _isTransactionSecure = false;
  String? _verificationError;
  String? _transactionError;

  bool get isUserVerified => _isUserVerified;
  bool get isTransactionSecure => _isTransactionSecure;
  String? get verificationError => _verificationError;
  String? get transactionError => _transactionError;

  // Verify User Identity (OTP + Biometric)
  Future<void> verifyUserIdentity(String userId) async {
    _verificationError = null;
    notifyListeners();

    try {
      _isUserVerified =
          await _securityService.performIdentityVerification(userId);
    } catch (e) {
      _verificationError = "Verification failed: $e";
      _isUserVerified = false;
    } finally {
      notifyListeners();
    }
  }

  // Secure Transaction with Encryption and AI Fraud Detection
  Future<void> secureTransaction(String transactionId) async {
    _transactionError = null;
    notifyListeners();

    try {
      _isTransactionSecure =
          await _securityService.performTransactionSecurity(transactionId);
    } catch (e) {
      _transactionError = "Transaction security failed: $e";
      _isTransactionSecure = false;
    } finally {
      notifyListeners();
    }
  }

  // Reset Verification Status
  void resetVerification() {
    _isUserVerified = false;
    _verificationError = null;
    notifyListeners();
  }

  // Reset Transaction Security Status
  void resetTransactionSecurity() {
    _isTransactionSecure = false;
    _transactionError = null;
    notifyListeners();
  }
}
