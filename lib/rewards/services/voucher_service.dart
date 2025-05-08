import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caching/rewards/model/voucher.dart';

class VoucherService {
  final CollectionReference _voucherCollection =
  FirebaseFirestore.instance.collection('vouchers');

  /// Fetch all vouchers from Firestore
  Future<List<Voucher>> displayVouchers() async {
    try {
      final snapshot = await _voucherCollection.get();
      return snapshot.docs
          .map((doc) => Voucher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  /// Fetch a single voucher by ID
  Future<Voucher?> displayVoucherById(String id) async {
    try {
      final doc = await _voucherCollection.doc(id).get();
      if (doc.exists) {
        return Voucher.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error fetching voucher by ID: $e');
    }
    return null;
  }
}
