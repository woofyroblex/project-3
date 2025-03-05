// lib/models/community_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityRole { member, moderator, admin }

class CommunityModel {
  final String communityId;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> members; // List of user IDs
  final Map<String, CommunityRole> roles; // User roles in the community
  final DateTime createdAt;

  CommunityModel({
    required this.communityId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.members,
    required this.roles,
    required this.createdAt,
  });

  // Convert Firestore document to CommunityModel instance
  factory CommunityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      communityId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      roles: Map<String, CommunityRole>.from(
        (data['roles'] ?? {}).map(
          (key, value) => MapEntry(key, CommunityRole.values[value]),
        ),
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert CommunityModel instance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'members': members,
      'roles': roles.map((key, value) => MapEntry(key, value.index)),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Get role as a readable string
  String getRoleAsString(CommunityRole role) {
    switch (role) {
      case CommunityRole.member:
        return 'Member';
      case CommunityRole.moderator:
        return 'Moderator';
      case CommunityRole.admin:
        return 'Admin';
    }
  }
}
