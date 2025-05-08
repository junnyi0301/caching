import 'package:cloud_firestore/cloud_firestore.dart';

class PointTransaction {
  final String id;
  final int amount;
  final DateTime timestamp;
  final String description;

  PointTransaction({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.description,
  });

  factory PointTransaction.fromMap(Map<String, dynamic> m, String docId) {
    return PointTransaction(
      id: docId,
      amount: (m['amount'] as int?) ?? 0,
      timestamp: (m['timestamp'] as Timestamp).toDate(),
      description: m['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'timestamp': Timestamp.fromDate(timestamp),
    'description': description,
  };
}