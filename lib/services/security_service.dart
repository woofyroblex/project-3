import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../services/fraud_detection_service.dart';

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FraudDetectionService _fraudDetection = FraudDetectionService();

  /// Checks if a user has a free use left
  Future<bool> hasFreeUseLeft(String userId) async {
    try {
      final userDoc =
          await _firestore.collection('subscriptions').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('freeUsesLeft')) {
          int freeUsesLeft = data['freeUsesLeft'] as int;
          return freeUsesLeft > 0;
        }
      }

      return false; // Default to no free uses left
    } catch (e) {
      debugPrint('Error checking free use: $e');
      return false;
    }
  }

  /// Validates user security (e.g., Biometric, OTP)
  Future<bool> validateUserSecurity(String userId) async {
    // Fixed issue
    await Future.delayed(const Duration(seconds: 2));
    return _simulateSecurityCheck();
  }

  /// Validates transaction security (fraud detection logic)
  Future<bool> validateTransactionSecurity(String transactionId) async {
    await Future.delayed(const Duration(seconds: 2));
    return _simulateFraudCheck();
  }

  Future<bool> performSecurityCheck(
      String userId, TransactionModel transaction) async {
    try {
      // Check user account age
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final createdAt = DateTime.parse(userData['createdAt']);
      final accountAge = DateTime.now().difference(createdAt).inDays;

      // Basic security checks
      if (accountAge < 1) return false;
      if (transaction.amount > 10000) return false;

      return true;
    } catch (e) {
      print('Security check failed: $e');
      return false;
    }
  }

  Future<bool> detectFraud(String userId, TransactionModel transaction) async {
    try {
      // Check transaction frequency
      final recentTransactions = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
          .get();

      // Suspicious if too many transactions in 24h
      if (recentTransactions.docs.length > 10) return true;

      // Suspicious if amount is too high
      if (transaction.amount > 5000) return true;

      return false;
    } catch (e) {
      print('Fraud detection failed: $e');
      return true; // Fail safe - treat as fraudulent if check fails
    }
  }

  /// Simulated security verification (Biometric, OTP, etc.)
  bool _simulateSecurityCheck() {
    return true; // Assume successful authentication
  }

  /// Simulated fraud detection check
  bool _simulateFraudCheck() {
    return true; // Assume transaction is safe
  }

  Future<bool> performIdentityVerification(String userId) async {
    try {
      // Check if biometric authentication is available
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        debugPrint('Biometric authentication not available');
        return false;
      }

      // Perform biometric authentication
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to verify your identity',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Update user verification status in Firestore
        await _updateUserVerificationStatus(userId);
      }

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during identity verification: $e');
      return false;
    }
  }

  Future<bool> performTransactionSecurity(String transactionId) async {
    try {
      // Get transaction data
      final docSnapshot =
          await _firestore.collection('transactions').doc(transactionId).get();

      if (!docSnapshot.exists) {
        debugPrint('Transaction not found');
        return false;
      }

      final transaction = docSnapshot.data() as Map<String, dynamic>;

      // Perform fraud detection
      bool isSecure = !(await _fraudDetection.analyzeTransaction(transaction));

      // Update transaction security status
      if (isSecure) {
        await _updateTransactionSecurityStatus(transactionId);
      }

      return isSecure;
    } catch (e) {
      debugPrint('Error during transaction security check: $e');
      return false;
    }
  }

  Future<void> _updateUserVerificationStatus(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'verificationStatus': 'verified',
      'lastVerified': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateTransactionSecurityStatus(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'securityStatus': 'verified',
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }
}
