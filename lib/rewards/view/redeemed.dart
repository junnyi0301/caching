import 'package:flutter/material.dart';
import 'package:caching/rewards/model/redeemed_voucher.dart';

class RedeemedVoucherPage extends StatelessWidget {
  final RedeemedVoucher redeemed;
  const RedeemedVoucherPage({Key? key, required this.redeemed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF5F7FF);
    final cardBg = const Color(0xFFFFF4B8);
    final headerBg = const Color(0xFFBBCFFF);

    String fmt(DateTime d) => d.toLocal().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Redeemed Voucher',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Transform.translate(
          offset: const Offset(0, -50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  redeemed.voucher.icon.startsWith('http')
                      ? Image.network(redeemed.voucher.icon, width: 80, height: 80)
                      : Image.asset(redeemed.voucher.icon, width: 80, height: 80),
                  const SizedBox(height: 16),

                  Text(
                    redeemed.voucher.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    redeemed.voucher.subtitle.isNotEmpty
                        ? redeemed.voucher.subtitle
                        : redeemed.voucher.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'COUPON CODE',
                    style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      redeemed.couponCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFFFD54F)),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Expiry Date',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fmt(redeemed.validFrom)} – ${fmt(redeemed.validUntil)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
