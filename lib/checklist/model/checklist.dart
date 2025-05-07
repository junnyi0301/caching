import 'package:cloud_firestore/cloud_firestore.dart';

class Checklist {
  final String checklistID;
  final String checkListTitle;
  final String checklistRemindDate;
  final String checkListStatus;
  final Map<String, dynamic> itemList;

  Checklist({
    required this.checklistID,
    required this.checkListTitle,
    required this.checklistRemindDate,
    required this.checkListStatus,
    required this.itemList
  });

  //Convert to a map
  Map<String, dynamic> toMap(){
    return{
      "ChecklistID" : checklistID,
      "ChecklistTitle" : checkListTitle,
      "ChecklistDate" : checklistRemindDate,
      "ChecklistStatus" : checkListStatus,
      "ItemList": itemList.map((key, item) => MapEntry(key, item.toMap()))
    };
  }
}