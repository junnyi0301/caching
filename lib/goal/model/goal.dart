import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String goalID;
  final String goalName;
  final String goalDescr;
  final double targetAmt;
  final String commitment;
  final double payAmt;
  final int duration;
  final String goalStatus;
  final Map<String, dynamic> personInvolve;
  final double ttlSaveAmount;

  Goal({
    required this.goalID,
    required this.goalName,
    required this.goalDescr,
    required this.targetAmt,
    required this.commitment,
    required this.payAmt,
    required this.duration,
    required this.goalStatus,
    required this.personInvolve,
    required this.ttlSaveAmount
  });

  //Convert to a map
  Map<String, dynamic> toMap(){
    return{
      "GoalID" : goalID,
      "GoalName" : goalName,
      "GoalDescription" : goalDescr,
      "TargetAmount" : targetAmt,
      "Commitment" : commitment,
      "PayAmount" : payAmt,
      "Duration" : duration,
      "GoalStatus" : goalStatus,
      "PersonInvolve": personInvolve,
      "TotalSaveAmount": ttlSaveAmount
    };
  }
}