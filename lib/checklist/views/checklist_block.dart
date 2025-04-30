import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/checklist/services/checklist_service.dart';
import 'checklist_page.dart';

final design = Design();
final ChecklistService _checklistService = ChecklistService();

class ChecklistBlock extends StatelessWidget {
  final String checklistID;
  final String checklistTitle;
  final String checklistStatus;
  final Map<String, dynamic> itemList;
  final void Function()? reload;

  const ChecklistBlock({
    super.key,
    required this.checklistID,
    required this.checklistTitle,
    required this.checklistStatus,
    required this.itemList,
    required this.reload
  });

  @override
  Widget build(BuildContext context) {

    void reloadPage(){
      if (reload != null) {
        reload!();
      }
    }

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      color: design.primaryButton,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(checklistTitle, style: design.subtitleText)
                ],
              ),
            ),
          ),
      ),
    );
  }
}
