import 'package:flutter/material.dart';
import 'design.dart';
import 'create_goal.dart';

final design = Design();

class Goal extends StatefulWidget {
  const Goal({super.key});

  @override
  State<Goal> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
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
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: design.primaryColor,
                    foregroundColor: Colors.black,
                    minimumSize: Size.fromHeight(40),
                    side: BorderSide(color: Colors.black, width: 2)
                  ),
                  child: Text("Create Goal", style: design.contentText),
                  onPressed: (){
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateGoal()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
