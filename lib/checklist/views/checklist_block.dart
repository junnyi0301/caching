import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/checklist/services/checklist_service.dart';
import 'checklist_page.dart';
import 'create_checklist_page.dart';
import 'package:intl/intl.dart';

final design = Design();
final ChecklistService _checklistService = ChecklistService();

class ChecklistBlock extends StatefulWidget {
  final String checklistID;
  final String checklistTitle;
  final String checklistDate;
  final String checklistStatus;
  final Map<String, dynamic> itemList;
  final void Function()? reload;

  const ChecklistBlock({
    super.key,
    required this.checklistID,
    required this.checklistTitle,
    required this.checklistDate,
    required this.checklistStatus,
    required this.itemList,
    required this.reload
  });

  @override
  State<ChecklistBlock> createState() => _ChecklistBlockState();
}

class _ChecklistBlockState extends State<ChecklistBlock> {


  String _latestChecklistStatus = "";
  @override
  void initState() {
    super.initState();
    _latestChecklistStatus = widget.checklistStatus;
    print(widget.checklistTitle);
    print(widget.checklistStatus);
    print(_latestChecklistStatus);
  }

  @override
  Widget build(BuildContext context) {

    void reloadPage(){
      if (widget.reload != null) {
        widget.reload!();
      }
    }

    void remChecklist() async{
      await _checklistService.remChecklist(widget.checklistID);
      reloadPage();
    }

    void delChecklistDialog() {

      AlertDialog delGoalAlertDialog = AlertDialog(
        title: Text('Delete Checklist'),
        content: Text("Are you sure to delete ${widget.checklistTitle} ?"),
        actions: [
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                SizedBox(width: 28),
                ElevatedButton(
                  onPressed: () {
                    // Call your delete function here
                    remChecklist();
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                ),
              ],
            ),
          ),
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return delGoalAlertDialog;
        },
      );
    }

    void changeDate() async{
      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day + 1);
      final DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: tomorrow,
        firstDate: tomorrow,
        lastDate: DateTime(today.year + 10),
      );

      await _checklistService.updateChecklistReminder(widget.checklistID);

      if (_picked != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(_picked);
        await _checklistService.updateChecklistDate(widget.checklistID, formattedDate);
        reloadPage();
      }
    }

    void updateReminder() async {
      if (widget.checklistDate.isNotEmpty) {
        await _checklistService.updateChecklistDate(widget.checklistID, "");
        reloadPage();
      } else {
        changeDate();
      }
    }

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      color: _latestChecklistStatus == "Active"? design.primaryButton: Color(0xFFD9D9D9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(widget.checklistTitle, style: design.subtitleText),

                  SizedBox(height: 10),

                  Row(
                    children: [

                      SizedBox(width: 15),

                      GestureDetector(
                        onTap: changeDate,
                        child: widget.checklistDate.isEmpty
                            ? Text("")
                            : Text(widget.checklistDate, style: design.contentText,),
                      ),

                      Spacer(),

                      GestureDetector(
                        onTap: updateReminder,
                        child: widget.checklistDate.isEmpty
                            ? Image.asset(
                          'assets/images/close_reminder.png',
                          height: 22,
                          width: 22,
                        )
                            : Image.asset(
                          'assets/images/open_reminder.png',
                          height: 22,
                          width: 22,
                        ),
                      ),

                      SizedBox(width: 1),

                      IconButton(onPressed: delChecklistDialog, icon: Icon(Icons.delete),),
                    ],
                  ),

                  SizedBox(height: 10),

                  _itemList(),

                  SizedBox(height: 10),

                  Align(
                    alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateChecklistPage(checklistType: "edit", checklistID: widget.checklistID))
                                ).then((_){
                                  print("reload");
                                  reloadPage();
                                });
                              }, child: Text("Edit Checklist")
                          )
                        ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _itemList(){
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.itemList.entries
          .where((entry) => entry.value['ItemStatus'] != "Inactive")
          .map<Widget>((entry) {
            final item = entry.value;
            final isCompleted = (item['ItemStatus'] == "Completed"); // true = complete; false = active

            return CheckboxListTile(
              title: Text(
                item['ItemName'],
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              value: isCompleted,
              onChanged: (_) async {
                String newStatus = isCompleted ? "Active" : "Completed";
                await _checklistService.updateItemStatus(widget.checklistID, item["ItemID"], newStatus);

                Map<String, dynamic> latestChecklistData = await _checklistService.getSpecificChecklist(widget.checklistID);

                setState(() {
                  widget.itemList[entry.key]['ItemStatus'] = newStatus;
                  _latestChecklistStatus = latestChecklistData["ChecklistStatus"];
                });

                if(_latestChecklistStatus == "Completed"){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Congratulation! You have completed ${widget.checklistTitle}!')),
                  );
                }
              },
            );
        }).toList(),
      ),
    );
  }

}
