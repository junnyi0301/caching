// lib/views/add_transaction.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../services/transaction_service.dart';
import '../../utilities/design.dart';
import '../model/transaction.dart';
import '../services/category.dart';

class AddPage extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddPage({Key? key, this.existingTransaction}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final design = Design();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _methodController = TextEditingController(text: 'Cash');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Define categories with labels and icons
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Shops', 'icon': Icons.shopping_cart, 'value': 'Shops'},
    {'label': 'Food', 'icon': Icons.fastfood, 'value': 'Food'},
    {'label': 'Entertainment', 'icon': Icons.movie, 'value': 'Entertainment'},
    {'label': 'Repairs', 'icon': Icons.build, 'value': 'Repairs'},
    {'label': 'Health', 'icon': Icons.health_and_safety, 'value': 'Health'},
    {'label': 'Travel', 'icon': Icons.card_travel, 'value': 'Travel'},
    {'label': 'Transport', 'icon': Icons.directions_bus, 'value': 'Transport'},
    {'label': 'Utility', 'icon': Icons.power, 'value': 'Utility'},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'label': 'Salary', 'icon': Icons.monetization_on, 'value': 'Salary'},
    {'label': 'Investments', 'icon': Icons.trending_up, 'value': 'Investments'},
    {'label': 'Bonus', 'icon': Icons.card_giftcard, 'value': 'Bonus'},
    {'label': 'Others', 'icon': Icons.more_horiz, 'value': 'Others'},
  ];

  String? _selectedCategory;

  bool _isExpenseSelected = true;
  List<Map<String, dynamic>> get currentCategories => _isExpenseSelected ? _categories : _incomeCategories;

  @override
  void initState() {
    super.initState();

    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _dateController.text = DateFormat('dd/MM/yyyy').format(tx.timestamp);
      _methodController.text = tx.method;
      _amountController.text = tx.amount.abs().toStringAsFixed(2);
      _selectedCategory = tx.category;
      _noteController.text = tx.note ?? '';
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _methodController.addListener(() => setState(() {}));
      _amountController.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _methodController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Display as DD/MM/YYYY
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {});
    }
  }

  bool get _isFormValid {
    return _selectedCategory != null &&
        _dateController.text.isNotEmpty &&
        _methodController.text.isNotEmpty &&
        _amountController.text.isNotEmpty;
  }

  Future<void> _saveToFirebaseAndReturn() async {
    if (!_isFormValid) return;

    // Parse the displayed date string back into a DateTime
    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);

    if (widget.existingTransaction == null) {
      await TransactionService.saveTransaction(
        category: _selectedCategory!,
        method: _methodController.text,
        timestamp: parsedDate,
        amount: _isExpenseSelected
          ? -double.parse(_amountController.text)
          : double.parse(_amountController.text),
        note: _noteController.text.trim(),
      );
    } else {
      final id = widget.existingTransaction!.id;

      await TransactionService.updateTransaction(
        id: id!,
        category: _selectedCategory!,
        method: _methodController.text,
        timestamp: parsedDate,
        amount: _isExpenseSelected
          ? -double.parse(_amountController.text)
          : double.parse(_amountController.text),
        note: _noteController.text.trim(),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingTransaction == null
            ? 'Transaction recorded successfully'
            : 'Transaction updated successfully'
          ),
          backgroundColor: Colors.green[600]
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    //const double maxContentWidth = 360;
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFB9D3FB),
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
        title: Text(
          'Add',
          style: design.subtitleText
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CategoryToggle(
              isExpenseSelected: _isExpenseSelected,
              onToggle: (bool selected) {
                setState(() {
                  _isExpenseSelected = selected;
                  _selectedCategory = null;
                });
              },
            ),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.center,
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 2,
                children: currentCategories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];

                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat['value']),
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                ? Colors.orange
                                : Colors.blue
                            ),
                            child: Icon(
                              cat['icon'],
                              color: Colors.white,
                              size: 28
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            cat['label'],
                            style: design.labelTitle
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 26),

            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: design.primaryButton,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 5, color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    _buildFormRow(
                      label: 'Date',
                      child: TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormRow(
                      label: 'Method',
                      child: TextField(
                        controller: _methodController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormRow(
                      label: 'Amount',
                      prefixText: 'RM',
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final newText = newValue.text;
                            if ('.'.allMatches(newText).length > 1) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormRow(
                      label: 'Note',
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                          hintText: 'Optional note...',
                          hintStyle: design.captionText
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isFormValid
                          ? _saveToFirebaseAndReturn
                          : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  "Missing Information"
                                ),
                                content: const Text(
                                  "Please fill out all fields before saving."
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.existingTransaction == null
                            ? 'Save Transaction'
                            : 'Update Transaction',
                          style: design.saveRecordText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    String? prefixText,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label :',
            style: design.formTitleText,
          ),
        ),
        Expanded(
          child: prefixText != null
          ? Row(
            children: [
              Text(
                prefixText,
                style: design.formTitleText,
              ),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
          )
          : child,
        ),
      ],
    );
  }
}
