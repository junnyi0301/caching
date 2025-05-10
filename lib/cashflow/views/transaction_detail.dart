import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utilities/design.dart';
import '../model/transaction.dart';
import '../views/add_transaction.dart';
import '../services/transaction_service.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction tx;
  const TransactionDetailPage({Key? key, required this.tx}) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Transaction tx;

  @override
  void initState() {
    super.initState();
    tx = widget.tx;
  }

  @override
  Widget build(BuildContext context) {
    final design = Design();
    final dateStr = DateFormat('dd/MM/yyyy').format(tx.timestamp);

    return Scaffold(
      backgroundColor: const Color(0xFFE7EEFD),
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        elevation: 0,
        title: Text('Transaction Details', style: design.subtitleText),
        centerTitle: true,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(width: 124),
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: design.primaryButton,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 5, color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: design.categoryColor(tx.category),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          design.categoryIcon(tx.category),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(tx.category, style: design.recordImportantText),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildDetailRow('Method', tx.method, design),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Amount',
                    '${tx.amount < 0 ? '-' : '+'} RM ${tx.amount.abs().toStringAsFixed(2)}',
                    design,
                    valueStyle: design.recordImportantText,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Date', dateStr, design),
                  if (tx.note != null && tx.note!.trim().isNotEmpty)
                    ...[
                      const SizedBox(height: 16),
                      _buildDetailRow('Note', tx.note!, design),
                    ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete this transaction?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && tx.id != null) {
                          await TransactionService.deleteTransaction(tx.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transaction deleted successfully'),
                                backgroundColor: Colors.green[600]
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: design.secondaryButton,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddPage(existingTransaction: tx),
                          ),
                        );

                        if (tx.id != null) {
                          final updated = await TransactionService.getTransactionById(tx.id!);
                          if (updated != null) {
                            setState(() {
                              tx = updated;
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: design.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value,
      Design design, {
        TextStyle? valueStyle,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: design.formTitleText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: valueStyle ?? design.contentText,
          ),
        ),
      ],
    );
  }
}
