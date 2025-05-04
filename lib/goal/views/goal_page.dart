import 'package:caching/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/services/goal_service.dart';
import 'create_goal_page.dart';
import 'goal_block.dart';
import 'package:caching/auth/auth_service.dart';

final design = Design();

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalState();
}

class _GoalState extends State<GoalPage> {
  final GoalService _goalService = GoalService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> activeGoal = [];
  List<Map<String, dynamic>> completeGoal = [];

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  void loadGoals() async {
    activeGoal = await _goalService.getActiveGoals();
    completeGoal = await _goalService.getCompletedGoals();
    setState(() {

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
      bottomNavigationBar: BottomNav(currentIndex: 1,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 290,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGoalPage(
                          goalType: "create",
                          goalID: "",
                        ),
                      ),
                    ).then((_) {
                      loadGoals();
                    });
                  },
                  child: Text('Create Goal', style: design.contentText),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: design.primaryColor,
                    foregroundColor: Colors.black,
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              activeGoal.isEmpty
                  ? Text("Create a Goal now.", style: design.contentText)
                  : Expanded(
                child: ListView(
                  children: [
                    if (activeGoal.isNotEmpty)
                      ...activeGoal.map((goal) => GoalBlock(
                        goalID: goal['GoalID'] ?? ' ',
                        goalName: goal['GoalName'] ?? ' ',
                        goalDescr: goal['GoalDescription'] ?? ' ',
                        targetAmt: goal['TargetAmount'] ?? 0.00,
                        commitment: goal['Commitment'] ?? ' ',
                        payAmt: goal['PayAmount'] ?? 0.00,
                        duration: goal['Duration'] ?? 0.00,
                        personInvolve: goal['PersonInvolve'] ?? {},
                        ttlSaveAmount: goal['TotalSaveAmount'] ?? 0.00,
                        reload: () => loadGoals(),
                        status: goal['GoalStatus'],
                      )),
                    if (completeGoal.isNotEmpty) ...[
                      ...completeGoal.map((goal) => GoalBlock(
                        goalID: goal['GoalID'] ?? ' ',
                        goalName: goal['GoalName'] ?? ' ',
                        goalDescr: goal['GoalDescription'] ?? ' ',
                        targetAmt: goal['TargetAmount'] ?? 0.00,
                        commitment: goal['Commitment'] ?? ' ',
                        payAmt: goal['PayAmount'] ?? 0.00,
                        duration: goal['Duration'] ?? 0.00,
                        personInvolve: goal['PersonInvolve'] ?? {},
                        ttlSaveAmount: goal['TotalSaveAmount'] ?? 0.00,
                        reload: () => loadGoals(),
                        status: goal['GoalStatus'],
                      )),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}