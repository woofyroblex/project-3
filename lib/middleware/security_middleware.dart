import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../services/fraud_detection_service.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';

class SecurityMiddleware {
  final TransactionService _transactionService;
  final FraudDetectionService _fraudDetectionService;
  final AuthService _authService;

  SecurityMiddleware({
    required TransactionService transactionService,
    required AuthService authService,
  })  : _transactionService = transactionService,
        _authService = authService,
        _fraudDetectionService = FraudDetectionService();

  Future<bool> validateTransaction(
      BuildContext context, TransactionModel transaction) async {
    try {
      // Verify user is authenticated
      if (_authService.currentUser == null) {
        _showError(context, 'User not authenticated');
        return false;
      }

      // Verify transaction exists and is valid
      bool isValid = await _transactionService
          .verifyTransaction(transaction.transactionId);
      if (!isValid) {
        _showError(context, 'Invalid transaction');
        return false;
      }

      // Check for fraud
      bool isFraudulent = await _fraudDetectionService.analyzeTransaction(
        transaction.toJson(),
      );

      if (isFraudulent) {
        _showError(context, 'Transaction flagged as potentially fraudulent');
        return false;
      }

      return true;
    } catch (e) {
      _showError(context, 'Transaction validation failed: $e');
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
