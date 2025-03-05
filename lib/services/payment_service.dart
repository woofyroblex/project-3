import 'package:flutter/foundation.dart';
import 'package:lafa/models/enums.dart';
import '../models/payment_model.dart';
import '../models/transaction_model.dart';

class PaymentService {
  // Mock database for payments
  final List<PaymentModel> _paymentDatabase = [];

  // Initiate Payment
  Future<PaymentModel> initiatePayment(
      double amount, String payerId, String receiverId) async {
    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }
      final payment = PaymentModel(
        paymentId: UniqueKey().toString(),
        amount: amount,
        payerId: payerId,
        receiverId: receiverId,
        status: PaymentStatus.pending,
        timestamp: DateTime.now(),
      );
      await _storePayment(payment);
      debugPrint('Payment initiated: $payment');
      return payment;
    } catch (e) {
      debugPrint('Payment initiation failed: $e');
      throw Exception('Payment initiation failed: $e');
    }
  }

  // Store payment in mock database
  Future<void> _storePayment(PaymentModel payment) async {
    _paymentDatabase.add(payment);
    debugPrint('Payment stored: ${payment.paymentId}');
  }

  // Split Transaction
  Future<TransactionModel> splitTransaction(PaymentModel payment) async {
    try {
      final double finderShare = 30;
      if (payment.amount < finderShare) {
        throw Exception('Payment amount too low to split.');
      }
      final double adminShare = payment.amount - finderShare;

      return TransactionModel(
        transactionId: UniqueKey().toString(),
        paymentId: payment.paymentId,
        amount: payment.amount,
        finderAmount: finderShare,
        adminAmount: adminShare,
        lostPersonId: payment.payerId,
        foundPersonId: payment.receiverId,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
        transactionType: TransactionType.finderFee,
      );
    } catch (e) {
      debugPrint('Transaction split failed: $e');
      throw Exception('Transaction split failed: $e');
    }
  }

  // Verify Payment
  Future<bool> verifyPayment(String paymentId) async {
    try {
      await Future.delayed(Duration(seconds: 2));
      debugPrint('Payment verified for ID: $paymentId');
      return true;
    } catch (e) {
      debugPrint('Payment verification failed: $e');
      throw Exception('Payment verification failed: $e');
    }
  }

  // Fetch Payment History
  Future<List<PaymentModel>> fetchPaymentHistory(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      // Filter payments by user ID (either as payer or receiver)
      final userPayments = _paymentDatabase
          .where((payment) =>
              payment.payerId == userId || payment.receiverId == userId)
          .toList();

      // Sort by timestamp descending (most recent first)
      userPayments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('Fetched ${userPayments.length} payments for user: $userId');
      return userPayments;
    } catch (e) {
      debugPrint('Failed to fetch payment history: $e');
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return _paymentDatabase
          .map((payment) => TransactionModel(
                transactionId: payment.paymentId,
                paymentId: payment.paymentId,
                amount: payment.amount,
                finderAmount: payment.amount * 0.1,
                adminAmount: payment.amount * 0.9,
                lostPersonId: payment.payerId,
                foundPersonId: payment.receiverId,
                status: TransactionStatus.pending,
                timestamp: payment.timestamp,
                transactionType:
                    TransactionType.finderFee, // Updated from finder_fee
              ))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch all transactions: $e');
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<bool> processRefund(String transactionId) async {
    try {
      final payment = _paymentDatabase.firstWhere(
        (p) => p.paymentId == transactionId,
        orElse: () => throw Exception('Payment not found'),
      );

      payment.status = PaymentStatus.refunded;

      await Future.delayed(Duration(seconds: 2));

      debugPrint('Refund processed for transaction: $transactionId');
      return true;
    } catch (e) {
      debugPrint('Failed to process refund: $e');
      return false;
    }
  }
}
