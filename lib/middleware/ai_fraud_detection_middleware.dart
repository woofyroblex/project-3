import 'package:flutter/material.dart';
import '../services/fraud_detection_service.dart';
import '../models/transaction_model.dart';

class AIFraudDetectionMiddleware {
  final FraudDetectionService _fraudDetectionService = FraudDetectionService();

  Future<bool> validateTransaction(
      BuildContext context, TransactionModel transaction) async {
    try {
      final isFraudulent = await _fraudDetectionService.analyzeTransaction(
        transaction.toJson(),
      );

      if (isFraudulent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Transaction flagged as potentially fraudulent')),
        );
        return false;
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error validating transaction: $e')),
      );
      return false;
    }
  }
}
