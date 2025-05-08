import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caching/rewards/model/voucher.dart';

class RedeemedVoucher {
  final String id;
  final String userId;
  final Voucher voucher;      // snapshot of voucher details at time of redemption
  final String couponCode;    // issued code for this redemption
  final DateTime redeemedAt;  // timestamp when redeemed
  final DateTime validFrom;   // start of valid usage window
  final DateTime validUntil;  // end of valid usage window
  final bool used;            // whether coupon has been used

  RedeemedVoucher({
    required this.id,
    required this.userId,
    required this.voucher,
    required this.couponCode,
    required this.redeemedAt,
    required this.validFrom,
    required this.validUntil,
    this.used = false,
  });

  factory RedeemedVoucher.fromMap(Map<String, dynamic> m, String docId) {
    // voucherData is stored as a sub-map, voucherId separately if needed
    final voucherMap = m['voucherData'] as Map<String, dynamic>? ?? {};
    final voucherId  = m['voucherId'] as String? ?? docId;
    final voucher    = Voucher.fromMap(voucherMap, voucherId);

    // issued timestamp and validity may be stored as Firestore Timestamps
    DateTime parseDate(dynamic d, DateTime fallback) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? fallback;
      return fallback;
    }

    final redeemedAt   = parseDate(m['redeemedAt'], DateTime.now());
    final validFrom    = parseDate(m['validFrom'], redeemedAt);
    final validUntil   = parseDate(m['validUntil'], redeemedAt.add(const Duration(days:30)));
    final couponCode   = m['couponCode'] as String? ?? '';
    final used         = m['used'] as bool? ?? false;
    final userId       = m['userId'] as String? ?? '';

    return RedeemedVoucher(
      id: docId,
      userId: userId,
      voucher: voucher,
      couponCode: couponCode,
      redeemedAt: redeemedAt,
      validFrom: validFrom,
      validUntil: validUntil,
      used: used,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'voucherId': voucher.id,
      'voucherData': voucher.toMap(),
      'couponCode': couponCode,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'used': used,
    };
  }

  /// Helper to format expiry range as string
  String get expiryRange {
    final from = "\${validFrom.toLocal().toString().split(' ')[0]}";
    final to   = "\${validUntil.toLocal().toString().split(' ')[0]}";
    return "\$from – \$to";
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
}
