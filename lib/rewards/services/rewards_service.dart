import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caching/rewards/model/voucher.dart';
import 'package:caching/rewards/model/redeemed_voucher.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's ID
  String? get _userId => _auth.currentUser?.uid;

  /// Fetch current user's points
  Future<int> getUserPoints() async {
    final userId = _userId;
    if (userId == null) return 0;

    try {
      final doc = await _db.collection('Users').doc(userId).get();
      final data = doc.data();
      if (data != null && data['points'] is int) {
        return data['points'] as int;
      }
    } catch (e) {
      print("Error fetching user points: $e");
    }
    return 0;
  }

  /// Update current user's points
  Future<void> updateUserPoints(int newPoints) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _db.collection('Users').doc(userId).update({'points': newPoints});
    } catch (e) {
      print("Error updating user points: $e");
    }
  }

  /// Generate an 8-character coupon code
  String _generateCouponCode([int length = 8]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Redeem a voucher and deduct points
  Future<void> redeemVoucher({
    required Voucher voucher,
    required int currentPoints,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in.');

    if (currentPoints < voucher.requiredPoints) {
      throw Exception('Not enough points to redeem this voucher');
    }

    final couponCode = _generateCouponCode();

    try {
      final ref = _db
          .collection('Users')
          .doc(userId)
          .collection('redeemedVouchers')
          .doc();

      await ref.set({
        'userId': userId,
        'voucherId': voucher.id,
        'voucherData': voucher.toMap(),
        'couponCode': couponCode,
        'redeemedAt': FieldValue.serverTimestamp(),
        'validFrom': voucher.validFrom,
        'validUntil': voucher.validUntil,
        'used': false,
      });

      // Deduct points
      await updateUserPoints(currentPoints - voucher.requiredPoints);
    } catch (e) {
      print("Error redeeming voucher: $e");
      rethrow;
    }
  }

  /// Fetch redeemed vouchers from Firestore
  Future<List<RedeemedVoucher>> fetchRedeemedVouchers() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final snap = await _db
          .collection('Users')
          .doc(userId)
          .collection('redeemedVouchers')
          .orderBy('redeemedAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => RedeemedVoucher.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching redeemed vouchers: $e");
      return [];
    }
  }
}
