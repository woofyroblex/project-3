import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for AI Match Status
enum AIMatchStatus { pending, matched, unmatched }

/// Enum for AI Fraud Detection Result
enum AIFraudStatus { clear, suspicious, fraudulent }

/// Enum for AI Image Enhancement Status
enum AIImageEnhancementStatus { notEnhanced, enhanced }

/// AI Match Model to handle lost and found item matching
class AIMatchModel {
  final String matchId;
  final String lostItemId;
  final String foundItemId;
  final AIMatchStatus matchStatus;
  final double matchConfidence;
  final DateTime matchedAt;

  AIMatchModel({
    required this.matchId,
    required this.lostItemId,
    required this.foundItemId,
    required this.matchStatus,
    required this.matchConfidence,
    required this.matchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'lostItemId': lostItemId,
      'foundItemId': foundItemId,
      'matchStatus': matchStatus.name,
      'matchConfidence': matchConfidence,
      'matchedAt': Timestamp.fromDate(matchedAt),
    };
  }

  factory AIMatchModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIMatchModel(
      matchId: data['matchId'],
      lostItemId: data['lostItemId'],
      foundItemId: data['foundItemId'],
      matchStatus:
          AIMatchStatus.values.firstWhere((e) => e.name == data['matchStatus']),
      matchConfidence: data['matchConfidence'],
      matchedAt: (data['matchedAt'] as Timestamp).toDate(),
    );
  }
}

/// AI Fraud Detection Model
class AIFraudDetection {
  final String reportId;
  final AIFraudStatus fraudStatus;
  final String reason;
  final DateTime checkedAt;

  AIFraudDetection({
    required this.reportId,
    required this.fraudStatus,
    required this.reason,
    required this.checkedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'fraudStatus': fraudStatus.name,
      'reason': reason,
      'checkedAt': Timestamp.fromDate(checkedAt),
    };
  }

  factory AIFraudDetection.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIFraudDetection(
      reportId: data['reportId'],
      fraudStatus:
          AIFraudStatus.values.firstWhere((e) => e.name == data['fraudStatus']),
      reason: data['reason'],
      checkedAt: (data['checkedAt'] as Timestamp).toDate(),
    );
  }
}

/// AI Image Enhancement Model
class AIImageEnhancement {
  final String imageId;
  final AIImageEnhancementStatus enhancementStatus;
  final String enhancedImageUrl;

  AIImageEnhancement({
    required this.imageId,
    required this.enhancementStatus,
    required this.enhancedImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageId': imageId,
      'enhancementStatus': enhancementStatus.name,
      'enhancedImageUrl': enhancedImageUrl,
    };
  }

  factory AIImageEnhancement.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIImageEnhancement(
      imageId: data['imageId'],
      enhancementStatus: AIImageEnhancementStatus.values
          .firstWhere((e) => e.name == data['enhancementStatus']),
      enhancedImageUrl: data['enhancedImageUrl'],
    );
  }
}
