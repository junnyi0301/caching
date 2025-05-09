import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/transaction.dart' as cf;

class TransactionService {
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _txCol {
    final uid = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('transactions');
  }

  Stream<List<cf.Transaction>> getTransactionsStream() {
    return _txCol
        .orderBy('timestamp', descending: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => cf.Transaction.fromMap(doc.data(), id: doc.id))
        .toList()
    );
  }

  static Future<void> saveTransaction({
    required String category,
    required String method,
    required DateTime timestamp,
    required double amount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final txRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('transactions');

    await txRef.add({
      'category':   category,
      'method':     method,
      'timestamp':  timestamp,
      'amount':    -amount,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateTransaction({
    required String id,
    required String category,
    required String method,
    required DateTime timestamp,
    required double amount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final txRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('transactions')
        .doc(id);

    await txRef.update({
      'category':   category,
      'method':     method,
      'timestamp':  timestamp,
      'amount':    -amount,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteTransaction(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final txRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('transactions')
        .doc(id);

    await txRef.delete();
  }

  static Future<cf.Transaction?> getTransactionById(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('transactions')
        .doc(id)
        .get();

    if (doc.exists) {
      return cf.Transaction.fromMap(doc.data()!, id: doc.id);
    } else {
      return null;
    }
  }
}
