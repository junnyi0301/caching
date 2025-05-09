import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String? id;
  final String category;
  final String method;
  final DateTime timestamp;
  final double amount;
  final String? note;

  const Transaction({
    this.id,
    required this.category,
    required this.method,
    required this.timestamp,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'category':   category,
    'method':     method,
    'timestamp':  timestamp,
    'amount':     amount,
    'note': note,
    'created_at': FieldValue.serverTimestamp(),
  };

  factory Transaction.fromMap(Map<String, dynamic> map, {String? id}) {
    return Transaction(
      id:        id,
      category:  map['category'] as String,
      method:    map['method']   as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      amount:    (map['amount']  as num).toDouble(),
      note: map['note'] as String?,
    );
  }
}
