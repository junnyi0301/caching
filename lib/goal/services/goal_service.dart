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
      final now = DateTime.now();

      Goal newGoal = Goal(
        goalID: now.millisecondsSinceEpoch.toString(),
        goalName: name,
        goalDescr: descr,
        targetAmt: target,
        commitment: comm,
        payAmt: pay,
        duration: duration,
        goalStatus: "Active",
        personInvolve: {
          //_auth
          "5YcvQw3al0fqW5CN5B9cZAmGnT52": {
            "TotalContribution": 0,
            now.toString(): {"Contribution": 0.00}
          }
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
      final now = DateTime.now();

      await _firestore.collection("goal").doc(goalID).update({
        "PersonInvolve.$userID": {
          "TotalContribution": 0,
          now.toString():{"Contribution": 0.00}
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
          .where("GoalStatus", isEqualTo: "Active")
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error in getAllGoals: $e");
      return [];
    }
  }

  Future<void> updateContri(String goalID, double contribution) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        String _currentDate = DateTime.now().toString();

        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        double ttlSaving = (goalData["TotalSaveAmount"]).toDouble();
        double ttlContribution = (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"]["TotalContribution"]).toDouble(); //_auth

        if (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate] != null){
          double currentContribution = (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate]["contribution"] ?? 0.00).toDouble();
          currentContribution += contribution;
          await _firestore.collection("goal").doc(goalID).update({
            "PersonInvolve.5YcvQw3al0fqW5CN5B9cZAmGnT52.$_currentDate.Contribution": currentContribution,
          });
        }else{
          await _firestore.collection("goal").doc(goalID).update({
          "PersonInvolve.5YcvQw3al0fqW5CN5B9cZAmGnT52.$_currentDate": {"Contribution": contribution},
          });
        }

        ttlContribution += contribution;
        ttlSaving += contribution;

        await _firestore.collection("goal").doc(goalID).update({
          "TotalSaveAmount": ttlSaving,
        });
        await _firestore.collection("goal").doc(goalID).update({
          "PersonInvolve.5YcvQw3al0fqW5CN5B9cZAmGnT52.TotalContribution": ttlContribution,
        });

        print("Contribution updated for user 5YcvQw3al0fqW5CN5B9cZAmGnT52 in goal $goalID");

      } else {

        print("Goal $goalID not found.");

      }
    } catch (e) {
      print("Error in updateContribution: $e");
      rethrow;
    }
  }
}