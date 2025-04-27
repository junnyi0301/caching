import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';

final design = Design();

class GoalBlock extends StatelessWidget {
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
    required this.goalName,
    required this.goalDescription,
    required this.targetAmt,
    required this.commitment,
    required this.payAmt,
    required this.duration,
    required this.personInvolve,
    required this.ttlSaveAmount
  });

  @override
  Widget build(BuildContext context) {
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

              Text("Goal Amount:", style: design.contentText,)
              Text("RM ${targetAmt.toStringAsFixed(2)}", style: design.contentText),

              SizedBox(height: 10),

              Text(goalDescription, style: design.captionText),
              SizedBox(height: 20),


              Row(
                //ElevatedButton(onPressed: () {}, child: Text("Top Up")),

              )
            ],
          ),
        ),
      ),
    );
  }
}
