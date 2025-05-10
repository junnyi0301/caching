import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caching/goal/services/goal_service.dart';
import 'package:flutter/services.dart';
import 'create_goal_page.dart';

final design = Design();
final GoalService _goalService = GoalService();

class GoalBlock extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalDescr;
  final double targetAmt;
  final String commitment;
  final double payAmt;
  final int duration;
  final Map<String, dynamic> personInvolve;
  final double ttlSaveAmount;
  final void Function()? reload;
  final String status;

  const GoalBlock({
    super.key,
    required this.goalID,
    required this.goalName,
    required this.goalDescr,
    required this.targetAmt,
    required this.commitment,
    required this.payAmt,
    required this.duration,
    required this.personInvolve,
    required this.ttlSaveAmount,
    required this.reload,
    required this.status
  });

  @override
  State<GoalBlock> createState() => _GoalBlockState();
}

class _GoalBlockState extends State<GoalBlock> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String currentUserID = _auth.currentUser!.uid;

    double progress = (widget.ttlSaveAmount / widget.targetAmt).clamp(0.0, 1.0);
    double progressPercent = progress * 100;

    String type;
    widget.commitment == "by Daily Amount" ? type = "today" : type = "this month";

    final _formKey = GlobalKey<FormState>();
    final topUpCtrl = TextEditingController();

    void reloadPage(){
      if (widget.reload != null) {
        widget.reload!();
      }
    }

    void topUpGoal() async {
      await _goalService.updateContribution(widget.goalID, double.parse(topUpCtrl.text));
      double currentTotal = widget.ttlSaveAmount + double.parse(topUpCtrl.text);
      if(currentTotal >= widget.targetAmt){
        await _goalService.updateGoalStatus(widget.goalID, "Completed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Congratulations! You earned 100 points for completing this goal.'),
            backgroundColor: Colors.green[600],
          ),
        );
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contribution added successfully.')),
      );

      reloadPage();
    }

    void topUpDialog() {
      AlertDialog topUpAlertDialog = AlertDialog(
        title: const Text('Contribute Amount'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: topUpCtrl,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(
              prefixText: 'RM ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an top up amount.';
              } else if (double.tryParse(value)! <= 0) {
                return 'Amount must be more than 0.';
              }
              return null;
            },
          ),
        ),
        actions: [
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),

                ),
                SizedBox(width: 28),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      topUpGoal();
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Confirm"),
                ),
              ],
            ),
          ),
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return topUpAlertDialog;
          }
      );
    }

    void delGoal() async{
      await _goalService.remGoal(widget.goalID);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal deleted successfully.')),
      );
      reloadPage();
    }

    void delGoalDialog() {
      AlertDialog delGoalAlertDialog = AlertDialog(
        title: Text('Delete Goal'),
        content: Text("Are you sure to delete ${widget.goalName} ?"),
        actions: [
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                SizedBox(width: 28),
                ElevatedButton(
                  onPressed: () {
                    // Call your delete function here
                    delGoal();
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                ),
              ],
            ),
          ),
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return delGoalAlertDialog;
        },
      );
    }

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      color: widget.status == "Active"? design.primaryButton: Color(0xFFD9D9D9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(widget.goalName, style: design.subtitleText),

                SizedBox(height: 5),
                Divider(color: widget.status == "Active"? Colors.orange: Colors.white),
                SizedBox(height: 5),

                Text("Goal Amount:", style: design.contentText),
                Text("RM ${widget.targetAmt.toStringAsFixed(2)}", style: design.subtitleText),

                SizedBox(height: 10),

                Text("Total Savings:", style: design.contentText),
                Text("RM ${widget.ttlSaveAmount.toStringAsFixed(2)}", style: design.subtitleText,),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Distribute content to left and right
                  children: [
                    Text("${progressPercent.toStringAsFixed(2)}%", style: design.contentText),
                  ],
                ),

                Stack(
                  children: [
                    Container(
                      width: 250,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    progress > 0
                        ?
                    Container(
                      width: ((){
                        double colorPercentage = progress * 250;
                        if (colorPercentage < 8){
                          colorPercentage = 8;
                        }
                        return colorPercentage;
                      })(),
                      height: 20,
                      decoration: BoxDecoration(
                        color: design.secondaryButton,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ): Container(
                      width: progress * 250,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Text(widget.goalDescr, style: design.captionText, textAlign: TextAlign.justify,),
                SizedBox(height: 20),

                // Contribution List
                Text("Contribution", style: design.contentText, textAlign: TextAlign.center,),
                _contributionList(),

                SizedBox(height: 5),
                Divider(color: widget.status == "Active"? Colors.orange: Colors.white),
                SizedBox(height: 5),

                // Your Own Contribution
                Text("You have Contributed:", style: design.captionText),
                SizedBox(height: 5),
                FutureBuilder<double>(
                  future: widget.commitment == "by Daily Amount"
                      ? _goalService.getDailyContribution(widget.goalID)
                      : _goalService.getMonthlyContribution(widget.goalID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...", style: design.contentText);
                    } else if (snapshot.hasError) {
                      return Text("Error loading your contribution.", style: design.contentText);
                    } else {
                      double ownContribute = snapshot.data ?? 0.0;
                      return
                        Text(
                          "RM ${ownContribute.toStringAsFixed(2)} / RM ${widget.targetAmt.toStringAsFixed(2)}",
                          style: design.contentText,
                        );
                    }
                  },
                ),
                Text(type, style: design.contentText,),

                SizedBox(height: 5),
                Divider(color: widget.status == "Active"? Colors.orange: Colors.white),
                SizedBox(height: 5),

                // Example of total contribution (optional)
                Text("Total Contribute", style: design.contentText),
                Text(
                  "RM ${(widget.personInvolve[currentUserID]?["TotalContribution"] ?? 0.0).toStringAsFixed(2)}",
                  style: design.contentText,
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: (){
                    topUpDialog();
                  },
                  child: Text("Contribute", style: design.contentText,),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(250, 20),
                    backgroundColor: design.primaryColor,
                    foregroundColor: Colors.black
                  ),
                ),

                SizedBox(height: 5),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateGoalPage(goalType: "edit",goalID: widget.goalID,)),
                    ).then((_) {
                      reloadPage();
                    });
                  },
                  child: Text('Edit', style: design.contentText),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(250, 20),
                      backgroundColor: design.primaryColor,
                      foregroundColor: Colors.black
                  ),
                ),

                SizedBox(height: 5),

                ElevatedButton(
                  onPressed: (){
                    delGoalDialog();

                  },
                  child: Text("Delete", style: design.contentText),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(250, 20),
                      backgroundColor: design.secondaryButton,
                      foregroundColor: Colors.black
                  ),
                )


              ],
            ),
          )

        ),
      ),
    );
  }

  Widget _contributionList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _goalService.getAllMemberContribution(widget.goalID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error loading contributions");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No contributions found.");
        } else {
          List<Map<String, dynamic>> contributions = snapshot.data!;
          contributions.sort((a, b) => b["totalContribution"].compareTo(a["totalContribution"]));

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              final contribution = contributions[index];
              final String userID = contribution["userID"];
              final double totalContribution = contribution["totalContribution"];

              return FutureBuilder<String?>(
                future: _goalService.getUserNameByID(userID),
                builder: (context, userSnapshot) {
                  final String userName = userSnapshot.data ?? "Unknown User";

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: design.primaryColor,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              userName,
                              style: design.contentText,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (() {
                                double percentage = 0;

                                widget.status == "Active"
                                    ? percentage = (totalContribution / widget.targetAmt) * 100
                                    : percentage = (totalContribution / widget.ttlSaveAmount) * 100;

                                int displayPercent = 0;
                                if (percentage == 0){
                                  displayPercent = 0;
                                } else if (percentage > 0 && percentage <= 1){
                                  displayPercent = 1;
                                } else if (percentage > 100){
                                  displayPercent = 100;
                                } else{
                                  displayPercent = percentage.round();
                                }

                                return "$displayPercent %";
                              })(),
                              style: design.contentText,
                              textAlign: TextAlign.end,
                            ),
                          ),

                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}