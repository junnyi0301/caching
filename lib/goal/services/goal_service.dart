import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caching/goal/model/goal.dart';

class GoalService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllFriends() async {
    try {
      final snapshot = await _firestore
          .collection("friendsList")
          .doc("5YcvQw3al0fqW5CN5B9cZAmGnT52") // _auth
          .collection("friends")
          .where("status", isEqualTo: "accepted")
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error in getAllFriends: $e");
      return [];
    }
  }

  Future<String> addNewGoal(String name, String descr, double target, String comm, double pay, int duration) async {
    try {

      Goal newGoal = Goal(
        goalID: DateTime.now().millisecondsSinceEpoch.toString(),
        goalName: name,
        goalDescr: descr,
        targetAmt: target,
        commitment: comm,
        payAmt: pay,
        duration: duration,
        goalStatus: "Active",
        personInvolve: {
          //_auth: {"contribution": 0.00}
          "5YcvQw3al0fqW5CN5B9cZAmGnT52":{"contribution": 0.00}
        },
        ttlSaveAmount: 0
      );

      await _firestore.collection("goal").doc(newGoal.goalID).set(newGoal.toMap());

      print("Goal created with ID: ${newGoal.goalID}");
      return newGoal.goalID;
    } catch (e) {
      print("Error in addNewGoal: $e");
      rethrow;
    }
  }

  Future<void> addUserToGoal(String goalID, String userID) async {
    try {
      await _firestore.collection("goal").doc(goalID).update({
        "PersonInvolve.$userID": {
          "contribution": 0
        }
      });
      print("User $userID added to goal $goalID");
    } catch (e) {
      print("Error in addUserToGoal: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllGoals() async{
    try {
      final snapshot = await _firestore
          .collection("goal")
          //.where("PersonInvolve.${_auth}", isGreaterThanOrEqualTo: {}
          .where("PersonInvolve.${"5YcvQw3al0fqW5CN5B9cZAmGnT52"}", isGreaterThanOrEqualTo: {})
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error in getAllGoals: $e");
      return [];
    }
  }

  Future<void> updateContri(String goalID, String userID, double contribution) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        double ttlSaving = (goalData["TotalSaveAmount"]).toDouble();
        double currentContribution = (goalData["PersonInvolve"][userID]["contribution"] ?? 0.00).toDouble();

        double newTtlSaving = ttlSaving + contribution;
        double newContribution = currentContribution + contribution;

        await _firestore.collection("goal").doc(goalID).update({
          "TotalSaveAmount": newTtlSaving,
        });
        await _firestore.collection("goal").doc(goalID).update({
          "PersonInvolve.$userID.contribution": newContribution,
        });
        print("Contribution updated for user $userID in goal $goalID");
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in updateContribution: $e");
      rethrow;
    }
  }
}