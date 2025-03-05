import 'package:myapp/models/enums.dart';

import '../services/security_service.dart';
import '../services/subscription_service.dart';
import '../services/payment_service.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionMiddleware {
  final SubscriptionService _subscriptionService;
  final SecurityService _securityService;
  final PaymentService _paymentService;

  TransactionMiddleware({
    SubscriptionService? subscriptionService,
    SecurityService? securityService,
    PaymentService? paymentService,
  })  : _subscriptionService = subscriptionService ?? SubscriptionService(),
        _securityService = securityService ?? SecurityService(),
        _paymentService = paymentService ?? PaymentService();

  // Validate Subscription and Payment Before Proceeding
  Future<bool> validateTransaction(
      UserModel user, TransactionModel transaction) async {
    // Check user subscription status
    bool hasAccess =
        await _subscriptionService.hasActiveSubscription(user.userId);
    if (!hasAccess) {
      int freeUsageLeft =
          await _subscriptionService.getFreeUsageCount(user.userId);
      if (freeUsageLeft <= 0) {
        throw Exception(
            'Subscription required after free usage. Please upgrade.');
      }
    }

    // Run security checks
    bool isSecure = await _securityService.performSecurityCheck(
      user.userId,
      transaction,
    );
    if (!isSecure) {
      throw Exception('Transaction blocked due to security concerns.');
    }

    // Run fraud detection
    bool isFraudulent = await _securityService.detectFraud(
      user.userId,
      transaction,
    );
    if (isFraudulent) {
      throw Exception('Transaction flagged for potential fraud.');
    }

    return true;
  }

  // Process Transaction
  Future<PaymentModel> processTransaction(
      UserModel payer, UserModel receiver, double amount) async {
    final transaction = TransactionModel(
      transactionId: DateTime.now().toString(),
      paymentId: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      finderAmount: amount * 0.1, // 10% for finder
      adminAmount: amount * 0.9, // 90% for app
      lostPersonId: payer.userId,
      foundPersonId: receiver.userId,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      transactionType: TransactionType.servicePayment,
    );

    bool isValid = await validateTransaction(payer, transaction);
    if (!isValid) throw Exception('Transaction validation failed.');

    // Initiate Payment
    PaymentModel payment = await _paymentService.initiatePayment(
      amount,
      payer.userId,
      receiver.userId,
    );

    // Split the transaction
    await _paymentService.splitTransaction(payment);

    // Verify Payment
    bool verified = await _paymentService.verifyPayment(payment.paymentId);
    if (!verified) throw Exception('Payment verification failed.');

    return payment;
  }

  Future<TransactionModel> processTransactionFromMap(
      Map<String, dynamic> data) async {
    try {
      // Convert string to TransactionStatus enum
      final status = TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TransactionStatus.pending,
      );

      // Convert string to TransactionType enum
      final type = TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['transactionType'],
        orElse: () => TransactionType.servicePayment,
      );

      return TransactionModel(
        transactionId: data['transactionId'] as String,
        amount: (data['amount'] as num).toDouble(),
        finderAmount: (data['finderAmount'] as num).toDouble(),
        adminAmount: (data['adminAmount'] as num).toDouble(),
        lostPersonId: data['lostPersonId'] as String,
        foundPersonId: data['foundPersonId'] as String,
        status: status,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        transactionType: type,
        paymentId: data['paymentId'] as String,
      );
    } catch (e) {
      throw FormatException('Invalid transaction data: $e');
    }
  }

  // Helper methods for enum conversion
  TransactionStatus stringToStatus(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => TransactionStatus.pending,
    );
  }

  TransactionType stringToType(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
      orElse: () => TransactionType.servicePayment,
    );
  }
}
