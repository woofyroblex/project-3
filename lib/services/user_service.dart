import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.userId)
          .update(user.toJson());
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  /// Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toJson());
    } catch (e) {
      print("Error creating user: $e");
    }
  }
}
