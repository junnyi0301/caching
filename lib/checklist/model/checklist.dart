import 'package:cloud_firestore/cloud_firestore.dart';

class Checklist {
  final String checklistID;
  final String checkListTitle;
  final String checklistDate;
  final String checkListStatus;

  Checklist({
    required this.checklistID,
    required this.checkListTitle,
    required this.checklistDate,
    required this.checkListStatus
  });

    //Convert to a map
  Map<String, dynamic> toMap(){
    return{
      "ChecklistID" : checklistID,
      "ChecklistTitle" : checkListTitle,
      "ChecklistDate" : checklistDate,
      "ChecklistStatus" : checkListStatus
    };
  }
}
