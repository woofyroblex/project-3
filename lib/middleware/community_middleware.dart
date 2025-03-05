import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/security_service.dart';
import '../services/payment_service.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';

class CommunityMiddleware {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final SecurityService _securityService = SecurityService();
  final PaymentService _paymentService = PaymentService();

  // Access Control Middleware
  Future<bool> validateAccess(UserModel user) async {
    try {
      // Check subscription status
      final bool isSubscribed = await _subscriptionService.isSubscribed();
      if (!isSubscribed) {
        final bool firstFreeUse =
            await _subscriptionService.hasFreeUseLeft(user.userId);
        if (!firstFreeUse) {
          return await _handlePayment(user);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Access validation failed: $e');
      return false;
    }
  }

  // Payment Handling Middleware
  Future<bool> _handlePayment(UserModel user) async {
    try {
      final PaymentModel payment =
          await _paymentService.initiatePayment(59, user.userId, 'admin');
      final verified = await _paymentService.verifyPayment(payment.paymentId);
      if (verified) {
        await _paymentService.splitTransaction(payment);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Payment handling failed: $e');
      return false;
    }
  }

  // Security Checks Middleware
  Future<bool> runSecurityChecks(UserModel user) async {
    try {
      final bool passedVerification = await _securityService
          .validateUserSecurity(user.userId); // Fixed issue
      if (!passedVerification) {
        throw Exception('Security validation failed.');
      }
      return true;
    } catch (e) {
      debugPrint('Security check failed: $e');
      return false;
    }
  }

  // Combine Middleware Validation
  Future<bool> validateUserAccess(UserModel user) async {
    final accessGranted = await validateAccess(user);
    final securityPassed = await runSecurityChecks(user);
    return accessGranted && securityPassed;
  }
}
