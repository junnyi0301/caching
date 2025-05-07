import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {

  final String itemID;
  final String itemName;
  final String itemStatus;

  ChecklistItem({
    required this.itemID,
    required this.itemName,
    required this.itemStatus
  });

  //Convert to a map
  Map<String, dynamic> toMap() {
    return {
      "ItemID" : itemID,
      "ItemName": itemName,
      "ItemStatus": itemStatus
    };
  }
}