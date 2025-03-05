class FraudDetectionModel {
  final String transactionId;
  final double amount;
  final String userId;
  final DateTime timestamp;

  FraudDetectionModel({
    required this.transactionId,
    required this.amount,
    required this.userId,
    required this.timestamp,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create model from JSON
  factory FraudDetectionModel.fromJson(Map<String, dynamic> json) {
    return FraudDetectionModel(
      transactionId: json['transactionId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      userId: json['userId'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create model from Map
  factory FraudDetectionModel.fromMap(Map<String, dynamic> map) {
    return FraudDetectionModel(
      transactionId: map['transactionId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method
  FraudDetectionModel copyWith({
    String? transactionId,
    double? amount,
    String? userId,
    DateTime? timestamp,
  }) {
    return FraudDetectionModel(
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool detectFraud() {
    return amount > 10000; // Example fraud detection rule
  }

  @override
  String toString() {
    return 'FraudDetectionModel(transactionId: $transactionId, amount: $amount, userId: $userId, timestamp: $timestamp)';
  }
}

class FraudDetectionService {
  final String apiKey;
  final String endpoint;

  FraudDetectionService({
    required this.apiKey,
    required this.endpoint,
  });

  Future<bool> detectFraud(FraudDetectionModel model) async {
    if (model.amount > 1000) {
      print('Suspicious transaction detected: ${model.transactionId}');
      return true;
    } else {
      return false;
    }
  }

  Future<void> analyzeTransaction(FraudDetectionModel model) async {
    try {
      bool isFraud = await detectFraud(model);
      if (isFraud) {
        print('Fraud detected for transaction: ${model.transactionId}');
      } else {
        print('Transaction is clean: ${model.transactionId}');
      }
    } catch (e) {
      print('Error during fraud detection: $e');
    }
  }
}
