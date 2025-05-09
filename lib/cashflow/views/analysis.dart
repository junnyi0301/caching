import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../bottomNav.dart';
import '../../utilities/design.dart';
import '../model/transaction.dart';
import '../views/transactions.dart';
import '../views/add_transaction.dart';
import '../services/transaction_service.dart';
import '../views/transaction_detail.dart';

class AnalysisPg extends StatefulWidget {
  const AnalysisPg({Key? key}) : super(key: key);
  @override
  _AnalysisPgState createState() => _AnalysisPgState();
}

class _AnalysisPgState extends State<AnalysisPg> {
  final design = Design();
  final svc = TransactionService();
  DateTime _selectedMonth = DateTime.now();
  bool _showDetails = false;

  String get _monthLabel => DateFormat.yMMM().format(_selectedMonth);

  Map<String, Map<String, dynamic>> _computeCategoryData(
      List<Transaction> txs) {
    final data = <String, Map<String, dynamic>>{};
    for (final tx in txs) {
      final d = tx.timestamp;
      if (d.year == _selectedMonth.year && d.month == _selectedMonth.month) {
        data.putIfAbsent(tx.category, () => {'sum': 0.0, 'count': 0});
        data[tx.category]!['sum'] = data[tx.category]!['sum'] + tx.amount.abs();
        data[tx.category]!['count'] = data[tx.category]!['count'] + 1;
      }
    }
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => (b.value['sum'] as double).compareTo(a.value['sum'] as double));

    return Map.fromEntries(sortedEntries);
  }

  List<PieChartSectionData> _buildChartSections(
      Map<String, Map<String, dynamic>> catData) {
    if (catData.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          radius: 35,
          title: '',
        ),
      ];
    }
    final total = catData.values.fold<double>(0, (t, e) => t + (e['sum'] as double));
    return catData.entries.map((entry) {
      final sum = entry.value['sum'] as double;
      final pct = total > 0 ? (sum / total * 100) : 0.0;
      final cat = entry.key.toLowerCase();
      return PieChartSectionData(
        value: sum,
        color: design.categoryColor(cat),
        radius: 35,
        title: '${pct.toStringAsFixed(1)}%',
        titleStyle: design.pieChartText,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis', style: design.subtitleText),
        centerTitle: true,
        backgroundColor: design.primaryColor,
      ),
      backgroundColor: const Color(0xFFE7EEFD),
      bottomNavigationBar: BottomNav(currentIndex: 2),
      body: StreamBuilder<List<Transaction>>(
        stream: svc.getTransactionsStream(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          final txs = snapshot.data ?? [];
          final preview = txs.take(3).toList();
          final catData = _computeCategoryData(txs);
          final totalSpending =
          catData.values.fold<double>(0, (t, e) => t + (e['sum'] as double));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 373,
                        decoration: ShapeDecoration(
                          color: design.primaryButton,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final picked = await showMonthPicker(
                                    context: context,
                                    initialDate: _selectedMonth,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  );
                                  if (picked != null){
                                    setState(() => _selectedMonth = picked);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _monthLabel,
                                      style: design.subtitleText
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down, size: 35),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          sectionsSpace: 4,
                                          centerSpaceRadius: 75,
                                          centerSpaceColor: Colors.white,
                                          sections: _buildChartSections(catData),
                                        )
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Total Spending',
                                            style: design.pieChartInnerTitle
                                          ),
                                          Text(
                                            'RM ${totalSpending.toStringAsFixed(2)}',
                                            style: design.pieChartInnerText
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 65),
                              if (_showDetails)
                                Column(
                                  children: catData.entries.map((e) {
                                    final cat = e.key;
                                    final sum = e.value['sum'] as double;
                                    final count = e.value['count'] as int;
                                    final pct = totalSpending > 0
                                        ? sum / totalSpending * 100
                                        : 0;
                                    final color = design.categoryColor(cat.toLowerCase());
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                design.categoryIcon(cat),
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '$cat - ${pct.toStringAsFixed(1)}% ($count)',
                                                style: design.contentText,
                                              ),
                                            ),
                                            Text(
                                              'RM ${sum.toStringAsFixed(2)}',
                                              style: design.contentText,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            thickness: 1,
                                            color: Colors.black26
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _showDetails = !_showDetails),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showDetails
                                        ? 'Hide details'
                                        : 'Show details',
                                      style: design.detailText
                                    ),
                                    Icon(
                                      _showDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 373,
                        decoration: ShapeDecoration(
                          color: design.primaryButton,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Transactions',
                                    style: design.subtitleText
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const TransactionsPage()
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                                    child: Row(
                                      children: [
                                        Text(
                                          'View all',
                                          style: design.viewAllText
                                        ),
                                        Icon(Icons.chevron_right, size: 25, color: Colors.black,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              preview.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No transactions record available.',
                                    style: design.contentText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                              : Column(
                                children: preview.map((tx) {
                                  return InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TransactionDetailPage(tx: tx),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              margin: const EdgeInsets.only(right: 12, top: 6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: design.categoryColor(tx.category),
                                              ),
                                              child: Icon(
                                                design.categoryIcon(tx.category),
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(tx.category, style: design.recordImportantText),
                                                  const SizedBox(height: 4),
                                                  Text(tx.method, style: design.captionText),
                                                ],
                                              ),
                                            ),

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${tx.amount < 0 ? '-' : ''}RM ${tx.amount.abs().toStringAsFixed(2)}',
                                                  style: design.recordImportantText,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat('dd/MM/yyyy').format(tx.timestamp),
                                                  style: design.captionText,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (tx != preview.last)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Divider(thickness: 1, color: Colors.black26),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPage())
          ),
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

