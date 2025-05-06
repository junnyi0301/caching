import 'package:flutter/material.dart';

/// Call this from your page when user taps “Filter”:
///   showModalBottomSheet(
///     context: context,
///     isScrollControlled: true,
///     backgroundColor: Colors.transparent,
///     builder: (_) => FilterBottomSheet(
///       initial: {'Active': false, 'Expired': false, 'Used': false},
///       onApply: (result) => print(result),
///     ),
///   );
class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> initial;
  final void Function(Map<String, bool> result) onApply;
  const FilterBottomSheet({
    Key? key,
    required this.initial,
    required this.onApply,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, ctl) => Container(
        decoration: BoxDecoration(
          color: Color(0xFFE6F0FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),

            // Checkboxes
            Expanded(
              child: ListView(
                controller: ctl,
                children: filters.keys.map((key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: filters[key],
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (v) => setState(() => filters[key] = v!),
                  );
                }).toList(),
              ),
            ),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      filters.updateAll((k, v) => false);
                    }),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                    ),
                    child: Text('Clear All', style: TextStyle(color: Colors.red)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApply(filters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFF0B3),
                    ),
                    child: Text('Confirm', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
