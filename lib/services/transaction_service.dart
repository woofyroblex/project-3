import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/transaction_model.dart';

abstract class TransactionService {
  Future<List<TransactionModel>> fetchUserTransactions(String userId);
  Future<TransactionModel> createTransaction({
    required double amount,
    required String lostPersonId,
    required String foundPersonId,
  });
  Future<List<TransactionModel>> getTransactions();
  Future<bool> verifyTransaction(String transactionId);
  Future<TransactionModel> addTransaction(
      TransactionModel transaction); // Added this line
}

class FirebaseTransactionService implements TransactionService {
  final FirebaseFirestore _firestore;
  final String _collection = 'transactions';

  FirebaseTransactionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.transactionId)
          .set(transaction.toMap());
      return transaction;
    } catch (e) {
      debugPrint('❌ Failed to add transaction: $e');
      throw Exception('Failed to add transaction');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required double amount,
    required String lostPersonId,
    required String foundPersonId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionModel>> fetchUserTransactions(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyTransaction(String transactionId) async {
    throw UnimplementedError();
  }
}
