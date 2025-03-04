import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/report_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final reportsCount = await _firestore.collection('reports').count().get();
      final transactionsCount =
          await _firestore.collection('transactions').count().get();

      return {
        'totalUsers': usersCount.count,
        'totalReports': reportsCount.count,
        'totalTransactions': transactionsCount.count,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<List<UserModel>> getRecentUsers() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent users: $e');
    }
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    try {
      final snapshot =
          await _firestore
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .limit(10)
              .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent transactions: $e');
    }
  }

  Future<List<ReportModel>> getRecentReports() async {
    try {
      final snapshot =
          await _firestore
              .collection('reports')
              .orderBy('dateReported', descending: true)
              .limit(10)
              .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent reports: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
