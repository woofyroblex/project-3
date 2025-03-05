import 'package:flutter/material.dart';
import 'package:lafa/models/user_model.dart';
import 'package:lafa/services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String _userId = '';

  final UserService _userService = UserService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get userId => _userId;
  String get username => _user?.name ?? '';
  String get email => _user?.email ?? '';
  String get profileImage => _user?.profileImageUrl ?? '';

  /// ✅ Fetch user data from Firestore
  Future<void> fetchUser(String userId) async {
    _setLoading(true);
    try {
      final fetchedUser = await _userService.getUserById(userId);
      if (fetchedUser != null) {
        _user = fetchedUser;
        _userId = fetchedUser.userId; // ✅ Assign userId when fetching user
      }
    } catch (e) {
      debugPrint("❌ Error fetching user: $e");
    }
    _setLoading(false);
  }

  /// ✅ Update user profile and sync with Firestore
  Future<void> updateUser(UserModel updatedUser) async {
    _setLoading(true);
    try {
      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      _userId = updatedUser.userId; // ✅ Update userId when user updates
    } catch (e) {
      debugPrint("❌ Error updating user: $e");
    }
    _setLoading(false);
  }

  /// ✅ Refresh user data only if logged in
  Future<void> refreshUserData() async {
    if (_user != null) {
      await fetchUser(_user!.userId);
    }
  }

  /// ✅ Logout the user and clear all data
  void logout() {
    _user = null;
    _userId = ''; // ✅ Clear userId on logout
    notifyListeners();
  }

  /// 🔄 Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
