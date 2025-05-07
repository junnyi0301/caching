import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caching/checklist/model/checklist.dart';
import 'package:caching/checklist/model/checklistItem.dart';
import 'package:caching/utilities/noti_service.dart';

import '../../utilities/notification.dart';

class ChecklistService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // add checklist
  Future<String> addNewChecklist(String title, String remind, List<String> itemList) async {
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

      return newChecklist.checklistID;
    } catch (e) {
      print("Error in addNewChecklist: $e");
      return "";
    }
  }

  // add new item into checklist
  Future<void> addNewItemIntoList(String checklistID, List<String> newItemList) async {
    try {
      print("Gonna Add");
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
        int index = itemListData.length + 1;
        print(index);
        print(newItemList.length);
        for (int i = 0; i < newItemList.length; i++) {
          itemListData[index.toString()] = ChecklistItem(
              itemID: index.toString(),
              itemName: newItemList[i],
              itemStatus: "Active"
          ).toMap();
          index++;
        }

        await _firestore
            .collection("checklist")
            .doc(currentUserID)
            .collection("userChecklist")
            .doc(checklistID)
            .update({"ItemList": itemListData});
      }else{
        print("Checklist ID $checklistID not found.");
      }
    } catch (e) {
      print("Error in addNowItemIntoList: $e");
      rethrow;
    }
  }

  // get all info of all checklist
  Future<List<Map<String, dynamic>>> getAllChecklist() async {
    try {
      String currentUserID = _auth.currentUser!.uid;

      final snapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .where("ChecklistStatus", isNotEqualTo: "Inactive")
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error in getAllChecklist: $e");
      return [];
    }
  }

  // get specific checklist data
  Future<Map<String, dynamic>> getSpecificChecklist(String checklistID) async {
    try {
      String currentUserID = _auth.currentUser!.uid;

      final snapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print("Error in getSpecificChecklist: $e");
      return {};
    }
  }

  // get specific checklist item list
  Future<Map<String, dynamic>> getSpecificChecklistItem(String checklistID) async {
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

        Map<String, dynamic> checklistItem = Map<String, dynamic>.from(checklistData["ItemList"]);

        return checklistItem;
      } else {
        print("Checklist $checklistID not found.");
        return {};
      }

    } catch (e) {
      print("Error in getSpecificChecklistItem: $e");
      return {}; // return empty map on error
    }
  }

  //rem checklist
  Future<void> remChecklist(String checklistID) async{
    try{

      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {

        await _firestore
            .collection("checklist")
            .doc(currentUserID)
            .collection("userChecklist")
            .doc(checklistID)
            .delete();

        print("Checklist ID $checklistID successfully deleted.");

      }else{
        print("Checklist ID $checklistID not found.");
      }

    } catch(e){
      print("Error in remChecklist: $e");
      rethrow;
    }
  }

  // update checklist status into active, complete
  Future<void> updateChecklistStatus(String checklistID, String newStatus) async{
    try {
      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {
        await _firestore.collection("checklist").doc(currentUserID).collection("userChecklist").doc(checklistID).update({
          "ChecklistStatus": newStatus,
        });
      } else {
        print("Checklist $checklistID not found.");
      }
    } catch (e) {
      print("Error in updateChecklistStatus: $e");
      rethrow;
    }
  }

  // update checklist title
  Future<void> updateChecklistTitle(String checklistID, String newTitle) async{
    try {
      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {
        await _firestore.collection("checklist").doc(currentUserID).collection("userChecklist").doc(checklistID).update({
          "ChecklistTitle": newTitle,
        });
      } else {
        print("Checklist $checklistID not found.");
      }
    } catch (e) {
      print("Error in updateChecklistTitle: $e");
      rethrow;
    }

  }

  // update checklist date
  Future<void> updateChecklistDate(String checklistID, String newDate) async{
    try {
      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {

        if(newDate == ""){
          await NotificationService().cancelChecklistNotification(checklistID.hashCode);
          await NotificationService().debugPrintPendingNotifications();
        }

        await _firestore.collection("checklist").doc(currentUserID).collection("userChecklist").doc(checklistID).update({
          "ChecklistDate": newDate,
        });

      } else {
        print("Checklist $checklistID not found.");
      }
    } catch (e) {
      print("Error in updateChecklistTitle: $e");
      rethrow;
    }
  }

  // update item into active, completed, inactive
  Future<void> updateItemStatus(String checklistID, String itemID, String newStatus) async{
    try {
      String currentUserID = _auth.currentUser!.uid;

      DocumentSnapshot checklistSnapshot = await _firestore
          .collection("checklist")
          .doc(currentUserID)
          .collection("userChecklist")
          .doc(checklistID)
          .get();

      if (checklistSnapshot.exists) {

        Map<String, dynamic> oldChecklistData = await getSpecificChecklistItem(checklistID);
        final oldActiveItem = oldChecklistData.entries.where((entry) =>
          entry.value['ItemStatus'] == 'Active'
        );
        bool oriComplete = false;
        if(oldActiveItem.isEmpty){
          oriComplete = true;
        }

        await _firestore
            .collection("checklist")
            .doc(currentUserID)
            .collection("userChecklist")
            .doc(checklistID)
            .update({
          "ItemList.$itemID.ItemStatus": newStatus,
        });

        print("Item $itemID status updated to $newStatus");


        Map<String, dynamic> newChecklistData = await getSpecificChecklistItem(checklistID);

        // if not delete
        if(newStatus != "Inactive"){

          final newActiveItem = newChecklistData.entries.where((entry) =>
          entry.value['ItemStatus'] == 'Active'
          );

          // Active to complete
          if (newActiveItem.isEmpty && oriComplete == false) {
            await updateChecklistStatus(checklistID, "Completed");
            await updateChecklistDate(checklistID, "");
            print("Checklist update to 'Completed'");
          }

          // Complete to active
          if(newActiveItem.isNotEmpty && oriComplete == true){
            await updateChecklistStatus(checklistID, "Active");
            print("Checklist update to 'Active'");
          }
        }

      } else {
        print("Checklist $checklistID not found.");
      }
    } catch (e) {
      print("Error in updateChecklistTitle: $e");
      rethrow;
    }
  }

  Future<String> getItemIDByName(String checklistID, String itemName) async {
    try {
      Map<String, dynamic> itemMap = await getSpecificChecklistItem(checklistID);

      for (var entry in itemMap.entries) {
        if (entry.value["ItemName"] == itemName) {
          return entry.key;
        }
      }

      return "";
    } catch (e) {
      print("Error in getItemIDByName: $e");
      return "";
    }
  }

  // either add or update item status when user edit the checklist
  Future<void> updateItem(String checklistID, List<String> newItem) async {
    try {
      Map<String, dynamic> existingItemsMap = await getSpecificChecklistItem(checklistID);

      List<String> existingItem = existingItemsMap.values
          .where((item) => item["ItemStatus"] != "Inactive")
          .map<String>((item) => item["ItemName"] as String)
          .toList();
      print(existingItem);

      // check to remove item
      bool remItem = false;
      for (String existItem in existingItem) {
        if (!newItem.contains(existItem)) {
          String id = await getItemIDByName(checklistID, existItem);
          await updateItemStatus(checklistID, id, "Inactive");
          remItem = true;
        }
      }

      // check to add item
      bool addItem = false;
      for (String nItem in newItem) {
        bool found = false;

        for (var entry in existingItemsMap.entries) {
          String existingName = entry.value["ItemName"];
          String existingStatus = entry.value["ItemStatus"];
          String itemId = entry.key;

          if (existingName == nItem) {
            found = true;

            if (existingStatus == "Inactive") {
              // Reactivate the item
              await updateItemStatus(checklistID, itemId, "Active");
              print("Reactivated existing item: $nItem");
            } else {
              print("Item $nItem already active or completed.");
            }

            break;
          }
        }

        if (!found) {
          // Add new item if not found in existing list
          await addNewItemIntoList(checklistID, [nItem]);
          addItem = true;
          print("Added new item: $nItem");
        }
      }

      if (addItem == true) {

        bool hasCompleted = existingItemsMap.values.any((item) => item["ItemStatus"] == "Completed");

        if (hasCompleted == true) {
          await updateChecklistStatus(checklistID, "Active");
        }

      } else if (remItem == true && addItem == false){

        Map<String, dynamic> newChecklistData = await getSpecificChecklistItem(checklistID);

        final newActiveItem = newChecklistData.entries.where((entry) =>
        entry.value['ItemStatus'] == 'Active'
        );

        if(newActiveItem.isEmpty){
          await updateChecklistStatus(checklistID, "Completed");
          print("Checklist update to 'Completed'");
        }
      }

    } catch (e) {
      print("Error in updateItem: $e");
      rethrow;
    }
  }

  Future<void> updateChecklistReminder(String checklistID) async {
    try {
      final checklistData = await getSpecificChecklist(checklistID);
      //final notiService = NotiService();

      if (checklistData["ChecklistDate"]?.isNotEmpty ?? false) {
        // await notiService.scheduleChecklistNotification(
        //   checklistId: checklistID,
        //   title: checklistData["ChecklistTitle"],
        //   dateString: checklistData["ChecklistDate"],
        // );

        print("Process Schedule Noti");

        final parts = checklistData["ChecklistDate"].split('-').map(int.parse).toList();
        //DateTime scheduleDateTime = DateTime(parts[0], parts[1], parts[2], 9, 0);

        print(parts[0]);
        print(parts[1]);
        print(parts[2]);
        print(DateTime(parts[0], parts[1], parts[2], 9, 0));
        //print(scheduleDateTime);

        String title = checklistData["ChecklistTitle"];

        await NotificationService().scheduleNotification(
            id: checklistID.hashCode,
            title: "Cachingg Chaecklist Reminder",
            body: "Remember to complete your $title by today!",
            payload: checklistData["ChecklistDate"],
            year: parts[0],
            month: parts[1],
            day: parts[2]
        );

        // DateTime now = DateTime.now();
        //
        // await NotificationService().scheduleNotification(
        //     id: 0,
        //     title: "Test",
        //     body: "Remember to complete your $title by today!",
        //     payload: checklistData["ChecklistDate"],
        //     scheduledTime: now.add(Duration(seconds: 20))
        // );
        // print("Schdule Noti: ${now.add(Duration(seconds: 20))}");
        // print("Now: ${now}");

        await NotificationService().debugPrintPendingNotifications();
        print("Reminder save successfully");
      } else {
        //await notiService.cancelChecklistNotification(checklistID);
        await NotificationService().cancelChecklistNotification(checklistID.hashCode);
      }
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      rethrow;
    }
  }

}