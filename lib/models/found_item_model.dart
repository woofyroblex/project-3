import 'package:cloud_firestore/cloud_firestore.dart';

// lib/models/found_item_model.dart

class FoundItemModel {
  final String id;
  final String description;
  final DateTime dateReported;
  final String locationFound;
  final String userId;
  final String? imageUrl;
  final String? imagePath; // Added for local file path
  final GeoPoint foundLocation; // Changed to GeoPoint for precise location
  final String status;

  const FoundItemModel({
    required this.id,
    required this.description,
    required this.dateReported,
    required this.locationFound,
    required this.userId,
    required this.foundLocation,
    this.imageUrl,
    this.imagePath,
    this.status = 'pending',
  });

  factory FoundItemModel.fromJson(Map<String, dynamic> json) {
    return FoundItemModel(
      id: json['id'] as String,
      description: json['description'] as String,
      dateReported: (json['dateReported'] as Timestamp).toDate(),
      locationFound: json['locationFound'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      foundLocation: json['foundLocation'] as GeoPoint,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'dateReported': Timestamp.fromDate(dateReported),
      'locationFound': locationFound,
      'userId': userId,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'foundLocation': foundLocation,
      'status': status,
    };
  }
}
