import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction.dart' as cf;

class TransactionService {
  final _col = FirebaseFirestore.instance.collection('transactions');

  Stream<List<cf.Transaction>> getTransactionsStream() {
    return _col
        .orderBy('timestamp', descending: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => cf.Transaction.fromMap(doc.data()))
        .toList());
  }

  static Future<void> saveTransaction({
    required String category,
    required String method,
    required DateTime date,
    required double amount,
  }) async {
    final data = {
      'category': category,
      'method': method,
      'timestamp': date,
      'amount': -amount,
      'created_at': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('transactions')
        .add(data);
  }
}
