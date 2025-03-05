import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, completed, failed, refunded, cancelled }

class PaymentModel {
  final String paymentId;
  final double amount;
  final String payerId;
  final String receiverId;
  PaymentStatus status; // Made non-final to allow status updates
  final DateTime timestamp;

  PaymentModel({
    required this.paymentId,
    required this.amount,
    required this.payerId,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() => {
        'paymentId': paymentId,
        'amount': amount,
        'payerId': payerId,
        'receiverId': receiverId,
        'status': status.toString(),
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      paymentId: doc.id,
      amount: (data['amount'] as num).toDouble(),
      payerId: data['payerId'] as String,
      receiverId: data['receiverId'] as String,
      status: PaymentStatus.values.firstWhere(
          (e) => e.toString() == data['status'],
          orElse: () => PaymentStatus.pending),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Keep JSON methods for API interactions
  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'amount': amount,
        'payerId': payerId,
        'receiverId': receiverId,
        'status': status.toString(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        paymentId: json['paymentId'] as String,
        amount: (json['amount'] as num).toDouble(),
        payerId: json['payerId'] as String,
        receiverId: json['receiverId'] as String,
        status: PaymentStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
            orElse: () => PaymentStatus.pending),
        timestamp: DateTime.parse(json['timestamp']),
      );
}
