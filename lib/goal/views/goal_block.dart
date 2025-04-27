import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:firebase_auth/firebase_auth.dart';

final design = Design();

class GoalBlock extends StatelessWidget {

  final String goalID;
  final String goalName;
  final String goalDescription;
  final double targetAmt;
  final String commitment;
  final double payAmt;
  final int duration;
  final Map<String, dynamic> personInvolve;
  final double ttlSaveAmount;

  const GoalBlock({
    super.key,
    required this.goalID,
    required this.goalName,
    required this.goalDescription,
    required this.targetAmt,
    required this.commitment,
    required this.payAmt,
    required this.duration,
    required this.personInvolve,
    required this.ttlSaveAmount,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String currentUserID = _auth.currentUser!.uid;

    double progress = (ttlSaveAmount / targetAmt).clamp(0.0, 1.0);
    double progressPercent = progress * 100;

    // double calcContribution(){
    //   if(commitment == "by Daily Amount"){
    //
    //   }
    // }
    //
    // double calcDailyContribution(){
    //
    // }
    //
    // String dailyContribution = "0.00";
    // double monthlyContribution = 0.00;
    //
    // if (personInvolve["5YcvQw3al0fqW5CN5B9cZAmGnT52"] != null) {
    //   var today = DateTime.now();
    //
    //   if (commitment == "by Daily Amount") {
    //
    //     dailyContribution = personInvolve["5YcvQw3al0fqW5CN5B9cZAmGnT52"][today.toString()]["Contribution"]?.toStringAsFixed(2) ?? "0.00";
    //
    //   }else {
    //     var currentMonth = today.month.toString();
    //     var currentYear = today.year.toString();
    //
    //   }
    //
    // }


    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      color: design.primaryButton,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goalName, style: design.subtitleText),
              SizedBox(height: 10),

              Text("Goal Amount:", style: design.contentText),
              Text("RM ${targetAmt.toStringAsFixed(2)}", style: design.contentText),

              SizedBox(height: 10),

              Text("Total Savings:", style: design.contentText),
              Text("RM ${ttlSaveAmount.toStringAsFixed(2)}", style: design.subtitleText),

              SizedBox(height: 10),

              Text("${progressPercent.toStringAsFixed(2)}%", style: design.contentText),

              // Progress Bar
              SizedBox(height: 8),
              Stack(
                children: [

                  Container( //bg bar
                    width: 250,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  progress > 0? Container( // progress bar
                    width: progress * 250, // 0.8 to make it not full width
                    height: 20,
                    decoration: BoxDecoration(
                      color: design.primaryColor,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ): Container(
                    width: 250, // 0.8 to make it not full width
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text(goalDescription, style: design.captionText,),

              SizedBox(height: 20),

              Text("Contribution:", style: design.contentText),

              Text("You had Contribute", style: design.contentText,),

              // commitment == "by Daily Amount"?
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "RM $dailyContribution / ${targetAmt.toStringAsFixed(2)}",
              //       style: design.subtitleText,
              //     ),
              //     Text("today", style: design.contentText),
              //   ],
              // ):
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "RM ${monthlyContribution.toStringAsFixed(2)} / ${targetAmt.toStringAsFixed(2)}",
              //       style: design.subtitleText,
              //     ),
              //     Text("This Month", style: design.contentText),
              //   ],
              // ),

              Text("Total Contribute", style: design.contentText,),
              Text("RM ${personInvolve["5YcvQw3al0fqW5CN5B9cZAmGnT52"]["TotalContribution"].toStringAsFixed(2) ?? '0.00'}")
            ],
          ),
        ),
      ),
    );
  }
}