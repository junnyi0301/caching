import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: RewardsPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  bool showVouchers = true;

  // grid vouchers
  final voucherItems = List.generate(4, (i) => {
    'icon': 'assets/images/grab_logo.png',
    'title': 'RM 20',
    'subtitle': 'Cash e-voucher',
    'points': '2000 pts',
  });
  // list rewards
  final rewardItems = List.generate(2, (i) => {
    'icon': 'assets/images/grab_logo.png',
    'title': 'Free Coffee',
    'date': 'Valid until 30 Apr 2025',
  });

  @override
  Widget build(BuildContext context) {
    final bgLightBlue = Color(0xFFCCE2FF);
    return Scaffold(
      backgroundColor: bgLightBlue,
      appBar: AppBar(
        backgroundColor: bgLightBlue,
        elevation: 0,
        centerTitle: true,
        title: Text('Rewards', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Points card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('3,000 Points', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('History', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showVouchers = true),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: showVouchers ? Colors.yellow[100] : Colors.white,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Vouchers', style: TextStyle(color: Colors.black, fontWeight: showVouchers ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showVouchers = false),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: showVouchers ? Colors.white : Colors.yellow[100],
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('My Rewards', style: TextStyle(color: Colors.black, fontWeight: showVouchers ? FontWeight.normal : FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Optional filter button under My Rewards
          if (!showVouchers)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[100],
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Filter', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: showVouchers
                  ? GridView.builder(
                itemCount: voucherItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0, // adjusted for smaller box
                ),
                itemBuilder: (context, index) {
                  final item = voucherItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(item['icon']!),
                        ),
                        SizedBox(height: 8),
                        Text(item['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(item['subtitle']!),
                        Spacer(),
                        Text(
                          item['points']!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18, // enlarged
                            fontWeight: FontWeight.bold, // bold
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : ListView.builder(
                itemCount: rewardItems.length,
                itemBuilder: (context, index) {
                  final item = rewardItems[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(item['icon']!),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(item['date']!),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Redeem', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[100],
        child: Icon(Icons.book, color: Colors.black),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.local_fire_department), onPressed: () {}),
              IconButton(icon: Icon(Icons.list), onPressed: () {}),
              SizedBox(width: 48),
              IconButton(icon: Icon(Icons.group), onPressed: () {}),
              IconButton(icon: Icon(Icons.person), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
