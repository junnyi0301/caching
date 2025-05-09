import 'package:caching/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:caching/rewards/view/rewards_details.dart';
import 'package:caching/rewards/view/redeemed.dart';
import 'package:caching/rewards/services/voucher_service.dart';
import 'package:caching/rewards/services/rewards_service.dart';
import 'package:caching/rewards/model/voucher.dart';
import 'package:caching/rewards/model/redeemed_voucher.dart';
import 'package:caching/utilities/design.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final VoucherService _voucherService = VoucherService();
  final RewardService _rewardService = RewardService();
  final design = Design();

  Future<List<Voucher>>? _vouchersFuture;
  Future<List<RedeemedVoucher>>? _redeemedFuture;
  int _userPoints = 0;
  bool _showVouchers = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final points       = await _rewardService.getUserPoints();
    final vouchersF    = _voucherService.displayVouchers();
    final redeemedF    = _rewardService.fetchRedeemedVouchers();
    setState(() {
      _userPoints       = points;
      _vouchersFuture   = vouchersF;
      _redeemedFuture   = redeemedF;
    });
  }

  void _onRedeem(Map<String, Object> redeemed) {
    _loadData();
    setState(() => _showVouchers = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgLightBlue = const Color(0xFFCCE2FF);

    return Scaffold(
      backgroundColor: design.secondaryColor,
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Rewards',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 4),
      body: Column(
        children: [
          // Points card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$_userPoints Points',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToggleButton('Vouchers', _showVouchers, () {
                  setState(() => _showVouchers = true);
                }),
                const SizedBox(width: 8),
                _buildToggleButton('My Rewards', !_showVouchers, () {
                  setState(() => _showVouchers = false);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _showVouchers
                  ? _buildVoucherGrid()
                  : _buildMyRewardsTabs(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.yellow[100] : Colors.white,
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? const [ BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2)) ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _buildVoucherGrid() {
    return FutureBuilder<List<Voucher>>(
      future: _vouchersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final vouchers = snapshot.data!..sort((a,b)=>a.requiredPoints.compareTo(b.requiredPoints));
        if (vouchers.isEmpty) {
          return const Center(child: Text('No vouchers available.'));
        }
        return GridView.builder(
          itemCount: vouchers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75),
          itemBuilder: (context, i) {
            final v = vouchers[i];
            return GestureDetector(
              onTap: () async {
                final redeemed = await Navigator.push<Map<String,Object>>(
                  context,
                  MaterialPageRoute(builder: (_) => RewardDetailsScreen(
                      voucher: v, userPoints: _userPoints
                  )),
                );
                if (redeemed != null) _onRedeem(redeemed);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [ BoxShadow(color: Colors.black26, blurRadius:6, offset: Offset(2,2)) ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(radius:30, backgroundColor: Colors.white, backgroundImage: AssetImage(v.icon)),
                    const SizedBox(height:12),
                    Text(v.title, style: const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
                    const SizedBox(height:4),
                    Text(v.subtitle, style: const TextStyle(fontSize:14)),
                    const SizedBox(height:8),
                    const Divider(color:Colors.grey),
                    const SizedBox(height:4),
                    Text(v.description, style: const TextStyle(fontSize:12,color:Colors.grey), textAlign: TextAlign.center),
                    const Spacer(),
                    Text(v.pointsLabel, style: const TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:Colors.black)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyRewardsTabs() {
    return FutureBuilder<List<RedeemedVoucher>>(
      future: _redeemedFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final redeemed = snap.data ?? [];
        if (redeemed.isEmpty) {
          return const Center(child: Text('No redeemed vouchers.'));
        }

        final now     = DateTime.now();
        final active  = redeemed.where((r)=>r.validUntil.isAfter(now)).toList();
        final expired = redeemed.where((r)=>r.validUntil.isBefore(now)).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.yellow[700],
                tabs: const [Tab(text:'Active'), Tab(text:'Expired')],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRedeemedList(active),
                    _buildRedeemedList(expired),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedeemedList(List<RedeemedVoucher> list) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (_,__) => const SizedBox(height:12),
      itemBuilder: (context, i) {
        final r = list[i];
        final expires = r.validUntil.toLocal().toString().split(' ')[0];
        return Container(
          decoration: BoxDecoration(
            color: design.primaryButton,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color:Colors.black12,blurRadius:4)],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius:24,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(r.voucher.icon),
              ),
              const SizedBox(width:12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.voucher.description,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Expires: $expires",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: design.submitButton,  // ← your new button color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RedeemedVoucherPage(redeemed: r),
                    ),
                  );
                },
                child: const Text('Use'),
              ),
            ],
          ),
        );
      },
    );
  }
}
