import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class TransactionModel {
  final String transactionId;
  final String paymentId;
  final double amount;
  final double finderAmount;
  final double adminAmount;
  final String lostPersonId;
  final String foundPersonId;
  final TransactionStatus status;
  final DateTime timestamp;
  final TransactionType transactionType;

  TransactionModel({
    required this.transactionId,
    required this.paymentId,
    required this.amount,
    required this.finderAmount,
    required this.adminAmount,
    required this.lostPersonId,
    required this.foundPersonId,
    required this.status,
    required this.timestamp,
    required this.transactionType,
  });

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'paymentId': paymentId,
        'amount': amount,
        'finderAmount': finderAmount,
        'adminAmount': adminAmount,
        'lostPersonId': lostPersonId,
        'foundPersonId': foundPersonId,
        'status': status.toString().split('.').last,
        'timestamp': timestamp.toIso8601String(),
        'transactionType': transactionType.toString().split('.').last,
      };

  Map<String, dynamic> toMap() => toJson(); // For backward compatibility

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromMap(data);
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        transactionId: map['transactionId'] as String,
        paymentId: map['paymentId'] as String,
        amount: (map['amount'] as num).toDouble(),
        finderAmount: (map['finderAmount'] as num).toDouble(),
        adminAmount: (map['adminAmount'] as num).toDouble(),
        lostPersonId: map['lostPersonId'] as String,
        foundPersonId: map['foundPersonId'] as String,
        status: TransactionStatus.values
            .firstWhere((e) => e.toString().split('.').last == map['status']),
        timestamp: DateTime.parse(map['timestamp'] as String),
        transactionType: TransactionType.values.firstWhere(
            (e) => e.toString().split('.').last == map['transactionType']),
      );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] as String,
      paymentId: json['paymentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      finderAmount: (json['finderAmount'] as num).toDouble(),
      adminAmount: (json['adminAmount'] as num).toDouble(),
      lostPersonId: json['lostPersonId'] as String,
      foundPersonId: json['foundPersonId'] as String,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['transactionType'],
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          transactionId == other.transactionId;

  @override
  int get hashCode => transactionId.hashCode;
}
