import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:lafa/models/enums.dart';
import '../models/transaction_model.dart';
import 'transaction_service.dart';

class FirebaseTransactionService implements TransactionService {
  final FirebaseFirestore _firestore;
  final String _collection = 'transactions';

  FirebaseTransactionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.transactionId)
          .set(transaction.toJson());

      return transaction;
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required double amount,
    required String lostPersonId,
    required String foundPersonId,
  }) async {
    try {
      final finderAmount = calculateFinderAmount(amount);
      final adminAmount = amount - finderAmount;
      final String paymentId = _firestore.collection(_collection).doc().id;

      final transaction = TransactionModel(
        transactionId: _firestore.collection(_collection).doc().id,
        paymentId: paymentId,
        amount: amount,
        finderAmount: finderAmount,
        adminAmount: adminAmount,
        lostPersonId: lostPersonId,
        foundPersonId: foundPersonId,
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
        transactionType: TransactionType.finderFee,
      );

      await addTransaction(transaction);
      return transaction;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> fetchUserTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('lostPersonId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    return fetchUserTransactions(userId);
  }

  double calculateFinderAmount(double totalAmount) {
    const finderPercentage = 0.10;
    return totalAmount * finderPercentage;
  }

  Future<void> updateTransactionStatus(
      String transactionId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transactionId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update transaction status: $e');
    }
  }

  @override
  Future<bool> verifyTransaction(String transactionId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(transactionId).get();

      if (!docSnapshot.exists) return false;

      final data = docSnapshot.data();
      return data?['status'] ==
          TransactionStatus.completed.toString().split('.').last;
    } catch (e) {
      debugPrint('Transaction verification failed: $e');
      return false;
    }
  }
}
