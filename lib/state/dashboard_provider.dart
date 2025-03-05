// lib/state/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService;
  UserModel? _user;
  List<NotificationModel> _notifications = [];
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._dashboardService);

  UserModel? get user => _user;
  List<NotificationModel> get notifications => _notifications;
  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userData = await _dashboardService.fetchUserData(userId);

      _user = userData['user'] as UserModel;
      _notifications = (userData['notifications'] as List)
          .map((n) => n as NotificationModel)
          .toList();
      _reports =
          (userData['reports'] as List).map((r) => r as ReportModel).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    if (_user != null) {
      await loadDashboard(_user!.userId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
