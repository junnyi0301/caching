import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String category;
  final String method;
  final DateTime timestamp;
  final double amount;

  const Transaction({
    required this.category,
    required this.method,
    required this.timestamp,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'method':    method,
      'timestamp': timestamp,
      'amount':    amount,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final tsValue = map['timestamp'];
    DateTime parsed;
    if (tsValue is DateTime) {
      parsed = tsValue;
    } else if (tsValue is Timestamp) {
      parsed = tsValue.toDate();
    } else if (tsValue is String) {
      parsed = DateTime.parse(tsValue);
    } else {
      throw FormatException('Cannot parse `timestamp` from value: $tsValue');
    }

    return Transaction(
      category:  map['category']  as String,
      method:    map['method']    as String,
      timestamp: parsed,
      amount:    (map['amount']   as num).toDouble(),
    );
  }
}
