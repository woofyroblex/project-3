//lib/services/dashboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserProfile(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        return _createNewUserProfile(userId);
      }

      return UserModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<UserModel> _createNewUserProfile(String userId) async {
    final newUser = UserModel(
      userId: userId,
      name: 'New User',
      email: '',
      phoneNumber: '',
      profileImageUrl: '',
      role: UserRole.user,
      verificationStatus: VerificationStatus.unverified,
      reputationScore: 0,
      isSubscribed: false,
    );

    await _firestore.collection('users').doc(userId).set(newUser.toJson());
    return newUser;
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.userId)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updateLastActive(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'lastActive': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to update last active: $e');
    }
  }

  Future<void> updateVerificationStatus(
      String userId, VerificationStatus status) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'verificationStatus': status.toString()});
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  Future<void> updateReputationScore(String userId, double newScore) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'reputationScore': newScore});
    } catch (e) {
      throw Exception('Failed to update reputation score: $e');
    }
  }

  Future<List<NotificationModel>> fetchUserNotifications(String userId) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    return [
      NotificationModel(
        id: "1",
        title: "Welcome",
        message: "Welcome to LAFA!",
        timestamp: DateTime.now(),
      ),
      NotificationModel(
          id: "2",
          title: "Update",
          message: "Your report has been updated.",
          timestamp: DateTime.now()),
    ];
  }

  Future<List<ReportModel>> fetchRecentReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReportModel(
          id: doc.id,
          itemType: data['itemType'] as String,
          description: data['description'] as String,
          dateReported: (data['dateReported'] as Timestamp).toDate(),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      // Fallback to dummy data for development
      final now = DateTime.now();
      return [
        ReportModel(
          id: "101",
          itemType: "Lost Wallet",
          description: "Black leather wallet lost near central park.",
          dateReported: now.subtract(Duration(days: 1)),
        ),
        ReportModel(
          id: "102",
          itemType: "Lost Phone",
          description: "iPhone 13 lost at the subway.",
          dateReported: now.subtract(Duration(days: 2)),
        ),
      ];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    // Simulate marking a notification as read
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data()!;

      // Get recent notifications
      final notifications = await fetchUserNotifications(userId);

      // Get recent reports
      final reports = await fetchRecentReports(userId);

      return {
        'user': UserModel.fromJson({...userData, 'id': userId}),
        'notifications': notifications,
        'reports': reports,
        'lastActive': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

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
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent users: $e');
    }
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.index)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  Future<List<UserModel>> getUsersByVerificationStatus(
      VerificationStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('verificationStatus', isEqualTo: status.index)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by verification status: $e');
    }
  }

  Future<void> updateUserReputation(String userId, int reputationScore) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'reputationScore': reputationScore,
      });
    } catch (e) {
      throw Exception('Failed to update user reputation: $e');
    }
  }

  Future<void> updateUserSubscription(
      String userId, bool isSubscribed, DateTime? subscriptionExpiry) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isSubscribed': isSubscribed,
        'subscriptionExpiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry)
            : null,
      });
    } catch (e) {
      throw Exception('Failed to update user subscription: $e');
    }
  }

  Future<void> logUserActivity(
      String userId, String activity, DateTime timestamp) async {
    try {
      await _firestore.collection('user_activities').add({
        'userId': userId,
        'activity': activity,
        'timestamp': timestamp,
      });
    } catch (e) {
      throw Exception('Failed to log user activity: $e');
    }
  }

  Future<void> logTransactionActivity(
      String transactionId, String activity, DateTime timestamp) async {
    try {
      await _firestore.collection('transaction_activities').add({
        'transactionId': transactionId,
        'activity': activity,
        'timestamp': timestamp,
      });
    } catch (e) {
      throw Exception('Failed to log transaction activity: $e');
    }
  }
}
