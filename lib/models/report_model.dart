import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String itemType;
  final String description;
  final DateTime dateReported;
  final DateTime timestamp;

  ReportModel({
    required this.id,
    required this.itemType,
    required this.description,
    required this.dateReported,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      itemType: data['itemType'] as String,
      description: data['description'] as String,
      dateReported: (data['dateReported'] as Timestamp).toDate(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      itemType: json['itemType'] as String,
      description: json['description'] as String,
      dateReported: json['dateReported'] is Timestamp
          ? (json['dateReported'] as Timestamp).toDate()
          : DateTime.parse(json['dateReported'] as String),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'description': description,
      'dateReported': Timestamp.fromDate(dateReported),
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
