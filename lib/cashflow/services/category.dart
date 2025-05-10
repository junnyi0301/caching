import 'package:flutter/material.dart';
import '../../utilities/design.dart';

class CategoryToggle extends StatefulWidget {
  final bool isExpenseSelected;
  final Function(bool) onToggle;

  const CategoryToggle({Key? key, required this.isExpenseSelected, required this.onToggle,}) : super(key: key);

  @override
  _CategoryToggleState createState() => _CategoryToggleState();
}

class _CategoryToggleState extends State<CategoryToggle> {
  late bool _isExpenseSelected;
  final design = Design();

  @override
  void initState() {
    super.initState();
    _isExpenseSelected = widget.isExpenseSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'Expense',
            isSelected: _isExpenseSelected,
            onTap: () {
              setState(() {
                _isExpenseSelected = true;
              });
              widget.onToggle(true);
            },
            isLeft: true,
          ),
          _buildToggleButton(
            label: 'Income',
            isSelected: !_isExpenseSelected,
            onTap: () {
              setState(() {
                _isExpenseSelected = false;
              });
              widget.onToggle(false);
            },
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? design.primaryButton : design.primaryColor,
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(12) : Radius.zero,
              right: isLeft ? Radius.zero : const Radius.circular(12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: design.contentText,
          ),
        ),
      ),
    );
  }
}
