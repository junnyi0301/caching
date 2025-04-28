import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caching/goal/model/goal.dart';
import 'package:intl/intl.dart';

class GoalService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //All friend in friend list
  Future<List<Map<String, dynamic>>> getAllFriends() async {
    try {
      final snapshot = await _firestore
          .collection("friendsList")
          .doc("5YcvQw3al0fqW5CN5B9cZAmGnT52") // _auth
          .collection("friends")
          .where("status", isEqualTo: "accepted")
          .get();

      return snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'uid': doc['uid']
        };
      }).toList();
    } catch (e) {
      print("Error in getAllFriends: $e");
      return [];
    }
  }

  //All goal a person involve
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

  //A specific goal data
  Future<Map<String, dynamic>> getGoalData(String goalID) async {
    final snapshot = await _firestore.collection("goal").doc(goalID).get();

    return snapshot.data() as Map<String, dynamic>;
  }

  //All uid contribute in one goal
  Future<List<String>> getAllMemberContributionID(String goalID) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> personInvolve = goalData["PersonInvolve"];

        List<String> memberID = personInvolve.keys.toList();
        memberID.remove("5YcvQw3al0fqW5CN5B9cZAmGnT52");

        return memberID;
      } else {
        print("Goal $goalID not found.");
        return [];
      }
    } catch (e) {
      print("Error in getAllMemberContribution: $e");
      return [];
    }
  }

  //All uid and name contribute in one goal (for match with selected friend)
  Future<List<Map<String, dynamic>>> getAllMemberContributionMap(String goalID) async {
    try {
      List<String> involveID = await getAllMemberContributionID(goalID);

      List<DocumentSnapshot> snapshots = await Future.wait(
          involveID.map((userId) => _firestore.collection("Users").doc(userId).get())
      );

      return snapshots.map((doc) {
        return {
          'name': doc['name'],
          'uid': doc['uid'],
        };
      }).toList();
    } catch (e) {
      print("Error in getAllMemberContribution: $e");
      return [];
    }
  }

  // All uid and ttl contribution of person involved in specific goal (for contribution list)
  Future<List<Map<String, dynamic>>> getAllMemberContribution(String goalID) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> personInvolve = goalData["PersonInvolve"];

        List<Map<String, dynamic>> memberContributions = [];

        personInvolve.forEach((userID, userData) {
          if (userData is Map<String, dynamic> && userData.containsKey("TotalContribution")) {
            memberContributions.add({
              "userID": userID,
              "totalContribution": (userData["TotalContribution"] ?? 0.0).toDouble()
            });
          }
        });

        return memberContributions;
      } else {
        print("Goal $goalID not found.");
        return [];
      }
    } catch (e) {
      print("Error in getAllMemberContribution: $e");
      return [];
    }
  }


  Future<double> getDailyContribution(String goalID) async{
    try {
      double dailyContribution = 0.0;
      String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists){
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;

        if (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate] != null){

          dailyContribution = (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate]["Contribution"] ?? 0.00).toDouble();

        }

        return dailyContribution;

      }else{
        print("Goal $goalID not found.");
        return -1;
      }
    } catch (e) {
      print("Error in getDailyContribution: $e");
      return -1;
    }
  }

  Future<double> getMonthlyContribution(String goalID) async {
    try {
      double monthlyContribution = 0.00;
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> userContributions = goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"];

        userContributions.forEach((key, value) {
          if (key == "TotalContribution") return;

          // Parse the date key
          DateTime contributionDate = DateTime.parse(key);

          if (contributionDate.year == currentYear && contributionDate.month == currentMonth) {
            double contributionAmount = (value["Contribution"] ?? 0.0).toDouble();
            monthlyContribution += contributionAmount;
          }
        });

        return monthlyContribution;

      } else {
        print("Goal $goalID not found.");
        return -1;
      }
    } catch (e) {
      print("Error in getMonthlyContribution: $e");
      return -1;
    }
  }

  Future<String?> getUserNameByID(String userID) async {
    try {
      final docSnapshot = await _firestore
          .collection("Users")
          .doc(userID)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['name'] ?? 'No Name';
      } else {
        print("User $userID not found.");
        return 'Unknown User';
      }
    } catch (e) {
      print("Error in getUserName: $e");
      return 'Unknown User';
    }
  }

  Future<String> addNewGoal(String name, String descr, double target, String comm, double pay, int duration) async {
    try {
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);

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
            currentDate.toString(): {
              "Contribution": 0.00
            }
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
      final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await _firestore.collection("goal").doc(goalID).update({
        "PersonInvolve.$userID": {
          "TotalContribution": 0,
          now.toString():{
            "Contribution": 0.00
          }
        }
      });
      print("User $userID added to goal $goalID");
    } catch (e) {
      print("Error in addUserToGoal: $e");
      rethrow;
    }
  }

  Future<void> updateContribution(String goalID, double contribution) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        double ttlSaving = (goalData["TotalSaveAmount"]).toDouble();
        double ttlContribution = (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"]["TotalContribution"]).toDouble();

        if (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate] != null) {
          double currentContribution = (goalData["PersonInvolve"]["5YcvQw3al0fqW5CN5B9cZAmGnT52"][_currentDate]["Contribution"] ?? 0.00).toDouble();
          currentContribution += contribution;

          await _firestore.collection("goal").doc(goalID).update({
            "PersonInvolve.5YcvQw3al0fqW5CN5B9cZAmGnT52.$_currentDate.Contribution": currentContribution,
          });
        } else {
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

  Future<void> editGoalName(String goalID, String name) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        if(goalData["GoalName"] != name){
          await _firestore.collection("goal").doc(goalID).update({
            "GoalName": name,
          });
        }
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in updateGoalName: $e");
      rethrow;
    }
  }

  Future<void> editGoalDescr(String goalID, String description) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        if(goalData["GoalDescription"] != description){
          await _firestore.collection("goal").doc(goalID).update({
            "GoalDescription": description,
          });
        }
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in updateGoalDescription: $e");
      rethrow;
    }
  }

  Future<void> remGoalFriend(String goalID, String friendID) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
        double ttlSaving = (goalData["TotalSaveAmount"]).toDouble();
        double ttlContribution = (goalData["PersonInvolve"][friendID]["TotalContribution"]).toDouble();

        ttlSaving -= ttlContribution;

        await _firestore.collection("goal").doc(goalID).update({
          "TotalSaveAmount": ttlSaving,
          "PersonInvolve.$friendID": FieldValue.delete(), // <--- THIS IS THE CORRECT WAY
        });
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in remGoalFriend: $e");
      rethrow;
    }
  }

  //Handle add or remove person involve
  Future<void> updateGoalMembers(String goalID, List<String> newSelectedUserIDs) async {
    try {
      // Fetch the existing goal
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {

        List<String> existingUserID = await getAllMemberContributionID(goalID);

        // Check for users to REMOVE
        for (String existingUserID in existingUserID) {
          if (existingUserID == "5YcvQw3al0fqW5CN5B9cZAmGnT52") continue;

          if (!newSelectedUserIDs.contains(existingUserID)) {
            await remGoalFriend(goalID, existingUserID);
          }
        }

        // Check for users to ADD
        for (String newUserID in newSelectedUserIDs) {
          if (newUserID == "5YcvQw3al0fqW5CN5B9cZAmGnT52") continue;
          if (!existingUserID.contains(newUserID)) {
            await addUserToGoal(goalID, newUserID);
          }
        }

        print("Goal members updated successfully.");
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in updateGoalMembers: $e");
    }

  }

  Future<void> updateGoalStatus(String goalID, String status) async {
    try {
      DocumentSnapshot goalSnapshot = await _firestore.collection("goal").doc(goalID).get();

      if (goalSnapshot.exists) {
        await _firestore.collection("goal").doc(goalID).update({
          "GoalStatus": status,
        });
      } else {
        print("Goal $goalID not found.");
      }
    } catch (e) {
      print("Error in updateDialogStatus: $e");
      rethrow;
    }
  }
}