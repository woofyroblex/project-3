import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user information in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'photoURL': null,
        'role': 'user',
      });

      return true;
    } catch (e) {
      print('Error during signup: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Verify phone code
  Future<bool> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      // Get verification ID from local storage or state management
      final verificationId = await _getStoredVerificationId();

      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      // Sign in with the credential
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('Phone verification failed: $e');
      return false;
    }
  }

  Future<String> _getStoredVerificationId() async {
    // Implement getting stored verification ID
    // This should be stored when initially requesting the phone verification
    return ''; // Replace with actual implementation
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  // Get user stream
  Stream<User?> get userStream => _auth.authStateChanges();
}
