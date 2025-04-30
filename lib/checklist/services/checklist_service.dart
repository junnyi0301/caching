import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caching/checklist/model/checklist.dart';
import 'package:caching/checklist/model/checklistItem.dart';

class ChecklistService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNewChecklist(String title, String remind, List<String> itemList) async {
    try {
      String currentUserID = _auth.currentUser!.uid;
      print(" hi, $currentUserID");

      Map<String, ChecklistItem> itemsMap = {};

      int index = 1;
      for (final itemName in itemList) {
        itemsMap[index.toString()] = ChecklistItem(
          itemID: index.toString(),
          itemName: itemName,
          itemStatus: "Active",
        );
        index++;
      }

      Checklist newChecklist = Checklist(
        checklistID: DateTime.now().millisecondsSinceEpoch.toString(),
        checkListTitle: title,
        checklistRemindDate: remind,
        checkListStatus: "Active",
        itemList: itemsMap,
      );

      await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(newChecklist.checklistID)
          .set(newChecklist.toMap());

    } catch (e) {
      print("Error in addNewChecklist: $e");
      rethrow;
    }
  }

  Future<void> addNowItemIntoList(String checklistID, List<String> newItemList) async {
    try {
      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {
        Map<String, dynamic> checklistData = checklistSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> itemListData = Map<String, dynamic>.from(checklistData["ItemList"] ?? {});
        for (int i = itemListData.length; i < newItemList.length; i++) {
          itemListData[i.toString()] = ChecklistItem(
              itemID: i.toString(),
              itemName: newItemList[i],
              itemStatus: "Active"
          ).toMap();
        }

        await _firestore
            .collection("checklist")
            .doc(currentUserID)
            .collection("user_checklists")
            .doc(checklistID)
            .update({"ItemList": itemListData});
      }
    } catch (e) {
      print("Error in addNowItemIntoList: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllChecklist() async {
    try {
      String currentUserID = _auth.currentUser!.uid;

      final snapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .where("ChecklistStatus", isEqualTo: "Active")
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error in getAllChecklist: $e");
      return [];
    }
  }

}