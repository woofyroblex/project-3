import 'package:flutter/material.dart';
import '../services/fraud_detection_service.dart';
import '../models/transaction_model.dart';

class FraudMiddleware {
  final FraudDetectionService _fraudDetectionService;

  FraudMiddleware() : _fraudDetectionService = FraudDetectionService();

  Future<bool> validateTransaction(
      BuildContext context, TransactionModel transaction) async {
    try {
      final isFraudulent = await _fraudDetectionService.analyzeTransaction(
        transaction.toJson(),
      );

      if (isFraudulent) {
        _showError(context, 'Transaction flagged as potentially fraudulent');
        return false;
      }

      return true;
    } catch (e) {
      _showError(context, 'Error validating transaction: $e');
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
