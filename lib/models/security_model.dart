//lib/models/security_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for different types of security events
enum SecurityEventType {
  loginAttempt,
  paymentAttempt,
  reportSubmission,
  suspiciousActivity,
}

/// Enum for fraud detection status
enum FraudDetectionStatus { clear, suspicious, fraudulent }

/// Enum for verification status
enum VerificationStatus { unverified, pending, verified }

/// Security Event Model to track all security-related actions
class SecurityEvent {
  final String eventId;
  final String userId;
  final SecurityEventType eventType;
  final String description;
  final DateTime eventTime;
  final FraudDetectionStatus fraudStatus;

  SecurityEvent({
    required this.eventId,
    required this.userId,
    required this.eventType,
    required this.description,
    required this.eventTime,
    required this.fraudStatus,
  });

  // Convert SecurityEvent instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'eventType': eventType.name,
      'description': description,
      'eventTime': Timestamp.fromDate(eventTime),
      'fraudStatus': fraudStatus.name,
    };
  }

  // Convert Firestore DocumentSnapshot to SecurityEvent instance
  factory SecurityEvent.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SecurityEvent(
      eventId: data['eventId'],
      userId: data['userId'],
      eventType: SecurityEventType.values
          .firstWhere((e) => e.name == data['eventType']),
      description: data['description'],
      eventTime: (data['eventTime'] as Timestamp).toDate(),
      fraudStatus: FraudDetectionStatus.values
          .firstWhere((e) => e.name == data['fraudStatus']),
    );
  }
}

/// User Security Verification Model
class UserVerification {
  final String userId;
  final VerificationStatus verificationStatus;
  final DateTime lastVerifiedDate;

  UserVerification({
    required this.userId,
    required this.verificationStatus,
    required this.lastVerifiedDate,
  });

  // Convert UserVerification instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'verificationStatus': verificationStatus.name,
      'lastVerifiedDate': Timestamp.fromDate(lastVerifiedDate),
    };
  }

  // Convert Firestore DocumentSnapshot to UserVerification instance
  factory UserVerification.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserVerification(
      userId: data['userId'],
      verificationStatus: VerificationStatus.values
          .firstWhere((e) => e.name == data['verificationStatus']),
      lastVerifiedDate: (data['lastVerifiedDate'] as Timestamp).toDate(),
    );
  }
}
