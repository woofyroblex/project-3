import 'package:cloud_firestore/cloud_firestore.dart';

// lib/models/lost_item_model.dart

class LostItemModel {
  final String id;
  final String description;
  final DateTime dateOfLoss;
  final String locationLost; // Changed from location to be more specific
  final String userId;
  final String? imageUrl;
  final String? imagePath; // Added for local file path
  final GeoPoint expectedLocation; // Added for AI matching
  final String status;

  const LostItemModel({
    required this.id,
    required this.description,
    required this.dateOfLoss,
    required this.locationLost,
    required this.userId,
    required this.expectedLocation,
    this.imageUrl,
    this.imagePath,
    this.status = 'pending',
  });

  factory LostItemModel.fromJson(Map<String, dynamic> json) {
    return LostItemModel(
      id: json['id'] as String,
      description: json['description'] as String,
      dateOfLoss: (json['dateOfLoss'] as Timestamp).toDate(),
      locationLost: json['locationLost'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      expectedLocation: json['expectedLocation'] as GeoPoint,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'dateOfLoss': Timestamp.fromDate(dateOfLoss),
      'locationLost': locationLost,
      'userId': userId,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'expectedLocation': expectedLocation,
      'status': status,
    };
  }
}
