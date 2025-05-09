import 'package:flutter/material.dart';
import 'package:caching/rewards/services/rewards_service.dart';
import 'package:caching/rewards/model/voucher.dart';
import 'package:caching/utilities/design.dart';

class RewardDetailsScreen extends StatelessWidget {
  final Voucher voucher;
  final int userPoints;

  final RewardService _rewardService = RewardService();
  final design = Design();

  RewardDetailsScreen({
    Key? key,
    required this.voucher,
    required this.userPoints,
  }) : super(key: key);

  static const List<String> _instructions = [
    "After pressing Redeem and confirming, go to My Rewards page and select the voucher.",
    "Copy the “PIN”.",
    "Open your Grab App, tap the “All” icon.",
    "Select “Gifts”.",
    "Tap the Gifts icon in the top right corner of your Grab App.",
    "Paste your e‑VOUCHER CODE.",
    "Select which Grab Service (e.g. TRANSPORTATION, FOODMART or EXPRESS).",
    "Choose your breakdown of the e‑Voucher denomination.",
    "Follow the purchase steps and tap “Apply”.",
    "Congratulations! You have successfully applied your e‑Voucher discount.",
  ];

  Future<void> _handleRedeem(BuildContext context) async {
    if (userPoints < voucher.requiredPoints) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Insufficient Points"),
          content: const Text("You do not have enough points to redeem this voucher."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    try {
      await _rewardService.redeemVoucher(
        voucher: voucher,
        currentPoints: userPoints,
      );
      Navigator.pop(context, {
        'icon': voucher.icon,
        'title': voucher.title,
        'subtitle': voucher.subtitle,
        'description': voucher.description,
        'cost': voucher.requiredPoints,
        'pointsLabel': voucher.pointsLabel,
      });
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: design.secondaryColor,
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reward Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: voucher.icon.startsWith('http')
                  ? Image.network(voucher.icon, fit: BoxFit.contain)
                  : Image.asset(voucher.icon, fit: BoxFit.contain),
            ),
          ),
          Expanded(
            child: Container(
              color: design.primaryButton,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voucher.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(voucher.subtitle,
                        style: const TextStyle(fontSize: 14, color: Colors.black)),
                    const SizedBox(height: 16),
                    Text("${voucher.requiredPoints} points",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Voucher Promo Code", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 4)],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '**********',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, letterSpacing: 4.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("Promo Code given upon claim",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 20),
                    const Text("How to use it",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _instructions.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text("${i + 1}. ${_instructions[i]}"),
                      ),
                    const Divider(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _handleRedeem(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design.submitButton,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Redeem"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
