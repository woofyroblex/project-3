//lib/models/reputation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReputationLevel { beginner, trusted, expert, legend }

class ReputationModel {
  final String userId;
  final int totalPoints;
  final int successfulReturns;
  final int reportsMade;
  final ReputationLevel level;
  final DateTime lastUpdated;

  ReputationModel({
    required this.userId,
    required this.totalPoints,
    required this.successfulReturns,
    required this.reportsMade,
    required this.level,
    required this.lastUpdated,
  });

  // Convert ReputationModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'successfulReturns': successfulReturns,
      'reportsMade': reportsMade,
      'level': level.name,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Convert Firestore DocumentSnapshot to ReputationModel instance
  factory ReputationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReputationModel(
      userId: data['userId'],
      totalPoints: data['totalPoints'],
      successfulReturns: data['successfulReturns'],
      reportsMade: data['reportsMade'],
      level: ReputationLevel.values.firstWhere((e) => e.name == data['level']),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Calculate reputation level based on points
  static ReputationLevel determineLevel(int points) {
    if (points < 100) return ReputationLevel.beginner;
    if (points < 300) return ReputationLevel.trusted;
    if (points < 600) return ReputationLevel.expert;
    return ReputationLevel.legend;
  }

  // Add points for successful actions
  ReputationModel addPoints(int points) {
    int updatedPoints = totalPoints + points;
    return ReputationModel(
      userId: userId,
      totalPoints: updatedPoints,
      successfulReturns: successfulReturns + 1,
      reportsMade: reportsMade,
      level: determineLevel(updatedPoints),
      lastUpdated: DateTime.now(),
    );
  }

  // Get readable string for reputation level
  String getLevelAsString() {
    switch (level) {
      case ReputationLevel.beginner:
        return "Beginner";
      case ReputationLevel.trusted:
        return "Trusted";
      case ReputationLevel.expert:
        return "Expert";
      case ReputationLevel.legend:
        return "Legend";
    }
  }
}
