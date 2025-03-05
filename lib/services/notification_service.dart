//lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<NotificationModel> _notifications = [];
  final List<ActivityModel> _recentActivities = [];
  bool _isInitialized = false;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  List<NotificationModel> get notifications => _notifications;
  List<ActivityModel> get recentActivities => _recentActivities;

  // Initialize Notification Service
  Future<void> initNotifications() async {
    if (_isInitialized) return;
    await _loadInitialData();
    _isInitialized = true;
    notifyListeners();

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else {
      print('❌ Notification permission denied');
    }

    String? token = await _firebaseMessaging.getToken();
    print("📲 FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 New Notification Received: ${message.notification?.title}");
      _showLocalNotification(message);
      fetchUnreadCount(); // Update unread count when a new notification arrives
    });

    await _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'lafa_channel',
      'LAFA Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "New Notification",
      message.notification?.body ?? "",
      details,
    );
  }

  Future<void> saveNotificationToFirestore({
    required String userId,
    required String title,
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    fetchUnreadCount(); // Update unread count after saving new notification
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});

    fetchUnreadCount(); // Update unread count after marking as read
  }

  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    _unreadCount = snapshot.docs.length;
    notifyListeners(); // Notify listeners when count updates
  }

  Future<void> _loadInitialData() async {
    // Simulated initial data load
    await Future.delayed(const Duration(seconds: 1));
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Welcome',
        message: 'Welcome to LAFA!',
        timestamp: DateTime.now(),
      ),
    ]);

    _recentActivities.addAll([
      ActivityModel(
        id: '1',
        type: ActivityType.report,
        description: 'New lost item reported',
        timestamp: DateTime.now(),
      ),
    ]);
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return _notifications;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 50) {
      _recentActivities.removeLast();
    }
    notifyListeners();
  }
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String description;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

enum ActivityType {
  report,
  found,
  match,
  payment,
}
