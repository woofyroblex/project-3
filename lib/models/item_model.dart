import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus {
  pending,
  approved,
  rejected,
  lost,
  found,
  resolved,
  cancelled
}

class ItemModel {
  final String itemId;
  final String userId;
  final String title;
  final String description;
  final ItemStatus status;
  final String category;
  final String imageUrl;
  final String photoUrl;
  final String videoUrl;
  final double confidence;
  final DateTime dateTime;
  final String country;
  final String state;
  final String district;
  final String exactLocation;

  ItemModel({
    required this.itemId,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.imageUrl,
    required this.photoUrl,
    required this.videoUrl,
    required this.confidence,
    required this.dateTime,
    required this.country,
    required this.state,
    required this.district,
    required this.exactLocation,
  });

  // Convert ItemModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'category': category,
      'imageUrl': imageUrl,
      'photoUrl': photoUrl,
      'videoUrl': videoUrl,
      'confidence': confidence,
      'dateTime': dateTime.toIso8601String(),
      'country': country,
      'state': state,
      'district': district,
      'exactLocation': exactLocation,
    };
  }

  // Convert Firestore DocumentSnapshot to ItemModel instance
  factory ItemModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      itemId: data['itemId'],
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      status: ItemStatus.values
          .firstWhere((e) => e.toString().split('.').last == data['status']),
      category: data['category'],
      imageUrl: data['imageUrl'],
      photoUrl: data['photoUrl'],
      videoUrl: data['videoUrl'],
      confidence: data['confidence'],
      dateTime: DateTime.parse(data['dateTime']),
      country: data['country'],
      state: data['state'],
      district: data['district'],
      exactLocation: data['exactLocation'],
    );
  }
}
