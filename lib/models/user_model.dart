//lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin }

enum VerificationStatus { unverified, pending, verified }

class UserModel {
  final String userId;
  final String? username;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final int reputationScore;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final int reportCount;
  final int foundItemCount;
  final double averageFoundItemValue;
  final String? profileImage;
  final DateTime? lastActive;

  const UserModel({
    required this.userId,
    this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.role,
    required this.verificationStatus,
    required this.reputationScore,
    required this.isSubscribed,
    this.subscriptionExpiry,
    this.reportCount = 0,
    this.foundItemCount = 0,
    this.averageFoundItemValue = 0.0,
    this.profileImage,
    this.lastActive,
  });

  /// Convert Firestore document to `UserModel`
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      userId: doc.id,
      username: data['username'] as String?,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
      role: _mapUserRole(data['role']),
      verificationStatus: _mapVerificationStatus(data['verificationStatus']),
      reputationScore: (data['reputationScore'] as int?) ?? 0,
      isSubscribed: (data['isSubscribed'] as bool?) ?? false,
      subscriptionExpiry: data['subscriptionExpiry'] != null
          ? (data['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      reportCount: (data['reportCount'] as int?) ?? 0,
      foundItemCount: (data['foundItemCount'] as int?) ?? 0,
      averageFoundItemValue:
          (data['averageFoundItemValue'] as num?)?.toDouble() ?? 0.0,
      profileImage: data['profileImage'] as String?,
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert JSON to `UserModel`
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      username: json['username'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      role: _mapUserRole(json['role']),
      verificationStatus: _mapVerificationStatus(json['verificationStatus']),
      reputationScore: (json['reputationScore'] as int?) ?? 0,
      isSubscribed: (json['isSubscribed'] as bool?) ?? false,
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.tryParse(json['subscriptionExpiry'])
          : null,
      reportCount: (json['reportCount'] as int?) ?? 0,
      foundItemCount: (json['foundItemCount'] as int?) ?? 0,
      averageFoundItemValue:
          (json['averageFoundItemValue'] as num?)?.toDouble() ?? 0.0,
      profileImage: json['profileImage'] as String?,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'])
          : null,
    );
  }

  /// Convert `UserModel` to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.index,
      'verificationStatus': verificationStatus.index,
      'reputationScore': reputationScore,
      'isSubscribed': isSubscribed,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'reportCount': reportCount,
      'foundItemCount': foundItemCount,
      'averageFoundItemValue': averageFoundItemValue,
      'profileImage': profileImage,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  /// Convert `UserModel` to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.index,
      'verificationStatus': verificationStatus.index,
      'reputationScore': reputationScore,
      'isSubscribed': isSubscribed,
      'subscriptionExpiry': subscriptionExpiry != null
          ? Timestamp.fromDate(subscriptionExpiry!)
          : null,
      'reportCount': reportCount,
      'foundItemCount': foundItemCount,
      'averageFoundItemValue': averageFoundItemValue,
      'profileImage': profileImage,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Helper method to update UserModel
  UserModel copyWith({
    String? username,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    VerificationStatus? verificationStatus,
    int? reputationScore,
    bool? isSubscribed,
    DateTime? subscriptionExpiry,
    int? reportCount,
    int? foundItemCount,
    double? averageFoundItemValue,
    String? profileImage,
    DateTime? lastActive,
  }) {
    return UserModel(
      userId: userId,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      reputationScore: reputationScore ?? this.reputationScore,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      reportCount: reportCount ?? this.reportCount,
      foundItemCount: foundItemCount ?? this.foundItemCount,
      averageFoundItemValue:
          averageFoundItemValue ?? this.averageFoundItemValue,
      profileImage: profileImage ?? this.profileImage,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Get role as a readable string
  String get roleAsString {
    return role == UserRole.admin ? "Admin" : "User";
  }

  /// Get verification status as a readable string
  String get verificationStatusAsString {
    switch (verificationStatus) {
      case VerificationStatus.unverified:
        return "Unverified";
      case VerificationStatus.pending:
        return "Pending";
      case VerificationStatus.verified:
        return "Verified";
    }
  }

  /// Map role from Firestore
  static UserRole _mapUserRole(dynamic value) {
    if (value is int && value >= 0 && value < UserRole.values.length) {
      return UserRole.values[value];
    }
    return UserRole.user; // Default to 'user'
  }

  /// Map verification status from Firestore
  static VerificationStatus _mapVerificationStatus(dynamic value) {
    if (value is int &&
        value >= 0 &&
        value < VerificationStatus.values.length) {
      return VerificationStatus.values[value];
    }
    return VerificationStatus.unverified; // Default to 'unverified'
  }

  // Add fromMap constructor for Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      role: _mapUserRole(map['role']),
      verificationStatus: VerificationStatus.values.firstWhere(
          (e) => e.toString() == map['verificationStatus'],
          orElse: () => VerificationStatus.unverified),
      reputationScore: (map['reputationScore'] as num?)?.toInt() ?? 0,
      isSubscribed: (map['isSubscribed'] as bool?) ?? false,
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? (map['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      reportCount: map['reportCount'] as int? ?? 0,
      foundItemCount: (map['foundItemCount'] as int?) ?? 0,
      averageFoundItemValue:
          (map['averageFoundItemValue'] as num?)?.toDouble() ?? 0.0,
      profileImage: map['profileImage'] as String?,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }
}
