import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caching/goal/services/goal_service.dart';
import 'create_goal_page.dart';

final design = Design();

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalState();
}

class _GoalState extends State<GoalPage> {
  final GoalService _goalService = GoalService();

  List<Map<String, dynamic>> allGoals = []; // Get all goal from firebase
  List<Map<String, dynamic>> goalsDetail = []; // diaplay all

  void loadGoals() async {
    allGoals = await _goalService.getAllGoals();
    setState(() {
      goalsDetail = allGoals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        title: Text("Goal", style: design.subtitleText),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CreateGoalPage())
                );
              }, child: Text('Create Goal', style: design.contentText),
              )
            ],
          ),
        ),
      ),
    );
  }
}
