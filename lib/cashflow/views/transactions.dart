import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction.dart' as cf;
import '../services/transaction_service.dart';
import '../../utilities/design.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final svc = TransactionService();
  final design = Design();

  final List<String> allCategories = [
    'shops',
    'food',
    'entertainment',
    'repairs',
    'health',
    'travel',
    'transportation',
    'utility',
  ];

  Set<String> selectedCategories = {};

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shops': return Icons.shopping_cart;
      case 'food': return Icons.fastfood;
      case 'entertainment': return Icons.movie;
      case 'repairs': return Icons.build;
      case 'health': return Icons.health_and_safety;
      case 'travel': return Icons.card_travel;
      case 'transportation': return Icons.directions_bus;
      case 'utility': return Icons.power;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EEFD),
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('History', style: design.subtitleText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
          iconSize: 30,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            minimumSize: WidgetStatePropertyAll(Size(36, 36)),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => StatefulBuilder(
                  builder: (ctx2, setModalState) {
                    return Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Filter by Category',
                              style: design.contentText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: allCategories.map((category) {
                                  return CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: selectedCategories.contains(category),
                                    onChanged: (sel) {
                                      setModalState(() {
                                        setState(() {
                                          if (sel == true) {
                                            selectedCategories.add(category);
                                          } else {
                                            selectedCategories.remove(category);
                                          }
                                        });
                                      });
                                    },
                                    secondary: Icon(getCategoryIcon(category)),
                                    title: Text(
                                      category[0].toUpperCase() + category.substring(1),
                                      style: design.filterTitle,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: SizedBox(
                              width: 300,
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: design.secondaryButton,
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() => selectedCategories.clear());
                                  });
                                },
                                icon: const Icon(Icons.clear, size: 20,),
                                label: Text('Clear Filters', style: design.contentText,),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<cf.Transaction>>(
        stream: svc.getTransactionsStream(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          final allTx = snap.data ?? [];
          final filtered = selectedCategories.isEmpty
              ? allTx
              : allTx.where((tx) => selectedCategories.contains(tx.category.toLowerCase())).toList();

          final Map<String, List<cf.Transaction>> grouped = {};
          for (var tx in filtered) {
            final dt = tx.timestamp;
            final key = DateFormat('MMMM yyyy').format(dt);
            grouped.putIfAbsent(key, () => []).add(tx);
          }

          if (grouped.isEmpty) {
            return Center(
              child: Text(
                'No transactions record available.',
                style: design.subtitleText,
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: grouped.entries.expand<Widget>((entry) {
              final month = entry.key;
              final txs = entry.value;
              return [
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                        month.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: design.recordImportantText
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: ShapeDecoration(
                      color: design.primaryButton,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 5, color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: txs.asMap().entries.map<Widget>((e) {
                        final i = e.key;
                        final tx = e.value;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        tx.category,
                                        style: design.recordImportantText
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        tx.method,
                                        style: design.captionText
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        '${tx.amount < 0 ? '-' : ''}RM ${tx.amount.abs().toStringAsFixed(2)}',
                                        style: design.recordImportantText
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        DateFormat('dd/MM/yyyy').format(tx.timestamp),
                                        style: design.captionText
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (i < txs.length - 1) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Colors.grey, thickness: 1),
                              const SizedBox(height: 12),
                            ]
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ];
            }).toList(),
          );
        },
      ),
    );
  }
}