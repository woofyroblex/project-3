import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider(this._transactionService);

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserTransactions(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _transactionService
          .fetchUserTransactions(userId); // Fixed method name

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load transactions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TransactionModel?> createTransaction({
    required double amount,
    required String lostPersonId,
    required String foundPersonId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final transaction = await _transactionService.createTransaction(
        amount: amount,
        lostPersonId: lostPersonId,
        foundPersonId: foundPersonId,
      );

      _transactions = [..._transactions, transaction];

      _isLoading = false;
      notifyListeners();

      return transaction;
    } catch (e) {
      _error = 'Failed to create transaction: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
