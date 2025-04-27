import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/services/goal_service.dart';
import 'create_goal_page.dart';
import 'goal_block.dart';

final design = Design();

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalState();
}

class _GoalState extends State<GoalPage> {
  final GoalService _goalService = GoalService();

  List<Map<String, dynamic>> allGoals = []; // Get all goals from Firebase

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  void loadGoals() async {
    allGoals = await _goalService.getAllGoals();
    setState(() {});
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGoalPage()),
                  ).then((_) {
                    loadGoals;
                  });
                },
                child: Text('Create Goal', style: design.contentText),
              ),
              SizedBox(height: 20),
              allGoals.isEmpty
                  ? Text("Create a Goal now.", style: design.contentText)
                  : Expanded(
                child: ListView.builder(
                  itemCount: allGoals.length,
                  itemBuilder: (context, index) {
                    var goal = allGoals[index];
                    return GoalBlock(
                      goalID: goal['GoalID'],
                      goalName: goal['GoalName'],
                      goalDescription: goal['GoalDescription'],
                      targetAmt: goal['TargetAmount'],
                      commitment: goal['Commitment'],
                      payAmt: goal['PayAmount'],
                      duration: goal['Duration'],
                      personInvolve: goal['PersonInvolve'],
                      ttlSaveAmount: goal['TotalSaveAmount']
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
