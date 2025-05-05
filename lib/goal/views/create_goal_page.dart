import 'package:caching/goal/views/goal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/services/goal_service.dart';

final design = Design();
final GoalService _goalService = GoalService();

class CreateGoalPage extends StatefulWidget {
  final String goalType;
  final String goalID;

  const CreateGoalPage({
    super.key,
    required this.goalType,
    required this.goalID
  });

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {

  final goalNameCtrl = TextEditingController();
  final goalDescCtrl = TextEditingController();
  final targetAmountCtrl = TextEditingController();
  final constPayAmountCtrl = TextEditingController();
  final friendSearchCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  String? _commitment = 'by Daily Amount';
  final _commitmentList = ['by Daily Amount', 'by Monthly Amount'];

  double _duration = 0;
  List<Map<String, dynamic>> allFriends = []; // All friends from firebase
  List<Map<String, dynamic>> filteredFriends = []; // Displayed friends
  List<Map<String, dynamic>> selectedFriends = []; // Selected friends

  final GlobalKey<FormFieldState> nameFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> targetFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> payFieldKey = GlobalKey<FormFieldState>();

  String _errorMsg = "";
  late var waitRun;

  @override
  void initState() {
    super.initState();
    loadFriends();

    if(widget.goalType == "edit"){
      loadGoalData();
    }

  }

  Future<void> waitFunc(String goalID) async{
    waitRun = await _goalService.getGoalData(goalID);
    print(waitRun);
  }

  void calcDuration() {
    final pay = double.tryParse(constPayAmountCtrl.text) ?? 0;
    final target = double.tryParse(targetAmountCtrl.text) ?? 0;

    setState(() {
      if (pay > 0) {
        _duration = target / pay;
      } else {
        _duration = 0;
      }
    });
  }

  void loadFriends() async {
    allFriends = await _goalService.getAllFriends();
    setState(() {
      filteredFriends = allFriends;
    });
  }

  void searchFriend() {
    String searchTerm = friendSearchCtrl.text.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      setState(() {
        filteredFriends = allFriends;
      });
    } else {
      setState(() {
        filteredFriends = allFriends.where((friend) =>
            friend['name'].toLowerCase().contains(searchTerm)
        ).toList();
      });
    }
  }

  void selectFriend(Map<String, dynamic> friend) {
    bool alreadySelected = selectedFriends.any((selected) => selected['uid'] == friend['uid']);

    if (!alreadySelected) {
      setState(() {
        selectedFriends.add(friend);
      });
    }
  }

  void addGoal(String name, String descr, double target, String comm, double pay, int duration, List<String> selectedFriends) async {
    String goalID = await _goalService.addNewGoal(name, descr, target, comm, pay, duration);

    if (selectedFriends.isNotEmpty) {
      for (var friendID in selectedFriends) {
        await _goalService.addUserToGoal(goalID, friendID);
      }
    }

    await waitFunc(goalID);
  }

  void loadGoalData() async {
    Map<String, dynamic> goalData = await _goalService.getGoalData(widget.goalID);
    List<Map<String, dynamic>> memberList = await _goalService.getAllMemberContributionMap(widget.goalID);

    setState(() {
      goalNameCtrl.text = goalData['GoalName'];
      goalDescCtrl.text = goalData['GoalDescription'] ?? '';
      targetAmountCtrl.text = goalData['TargetAmount'].toString();
      constPayAmountCtrl.text = goalData['PayAmount'].toString();
      _commitment = goalData['Commitment'];

      double target = double.parse(targetAmountCtrl.text);
      double pay = double.parse(constPayAmountCtrl.text);
      _duration = target / pay;

      selectedFriends = memberList;
    });
  }

  void editGoal(String name, String descr, List<String> selectedFriends){
    _goalService.editGoalName(widget.goalID, name);
    _goalService.editGoalDescr(widget.goalID, descr);
    _goalService.updateGoalMembers(widget.goalID, selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        leading: Container(
          child: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        title: widget.goalType == "create"? Text("Create Goal", style: design.subtitleText)
        : Text("Edit Goal", style: design.subtitleText),
        centerTitle: true,
      ),
      body: Container(
        color: design.secondaryColor,
        padding: const EdgeInsets.all(20),
        child: Container(
          color: design.primaryButton,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Text(widget.goalType == "create"? "Create Goal" : "Edit Goal", style: design.subtitleText,),

                  Text(widget.goalType == "create"? "All field with * must be filled in." : "All field with * must be filled in.", style: design.captionText, textAlign: TextAlign.center),
                  Text(widget.goalType == "create"? "" : "Only goal name, goal description and friend contribution can be edit.", style: design.captionText, textAlign: TextAlign.center),
                  SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Column(
                        children: [
                          Text("Goal Details", style: design.contentText,),
                        ],
                      ),
                    ),
                  ),

                  TextFormField(
                    key: nameFieldKey,
                    controller: goalNameCtrl,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                        labelText: 'Goal Name*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter goal name.';
                      } else if (value.length > 15) {
                        return 'Please enter within 15 words';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    controller: goalDescCtrl,
                    decoration: const InputDecoration(labelText: 'Goal Description'),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    readOnly: widget.goalType == "create" ? false : true,
                    key: targetFieldKey,
                    controller: targetAmountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    decoration: InputDecoration(
                      labelText: 'Target Amount*',
                      prefixText: 'RM ',
                      labelStyle: TextStyle(
                        color: _errorMsg == "" ? Colors.black : Colors.red,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _errorMsg == "" ? Colors.black : Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _errorMsg == "" ? Colors.black : Colors.red, width: 2),
                      )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter target amount.';
                      } else if (double.tryParse(value)! <= 0) {
                        return 'Target amount must be more than 0.';
                      }
                      return null;
                    },
                    onChanged: (_) => calcDuration(),
                  ),

                  SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: "Commitment*"
                    ),
                    value: _commitment,
                    items: _commitmentList.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: widget.goalType == "create"
                        ? (String? value) {
                          setState(() {
                            _commitment = value;
                          });
                        }: null,
                    validator: (value) =>
                    value == null ? 'Please select commitment' : null,
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    readOnly: widget.goalType == "create" ? false : true,
                    key: payFieldKey,
                    controller: constPayAmountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    decoration: InputDecoration(
                      labelText: _commitment == 'by Daily Amount'
                          ? 'Daily Pay Amount*'
                          : 'Monthly Pay Amount*',
                      prefixText: 'RM ',
                      labelStyle: TextStyle(
                        color: _errorMsg == "" ? Colors.black : Colors.red,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _errorMsg == "" ? Colors.black : Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _errorMsg == "" ? Colors.black : Colors.red, width: 2),
                      )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pay amount.';
                      }else if(double.tryParse(value)! <= 0){
                        return "Please enter more than 0.";
                      }
                      return null;
                    },
                    onChanged: (_) => calcDuration(),
                  ),

                  SizedBox(height: 35),

                  Container(
                    width: 235,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)), // Fixed parentheses
                      border: Border.all(
                        color: design.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _commitment == 'by Daily Amount'
                              ? "Duration: ${_duration.toStringAsFixed(0)} day(s)"
                              : "Duration: ${_duration.toStringAsFixed(0)} month(s)",
                          style: design.contentText,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 50),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Column(
                        children: [
                          Text("Collaborator", style: design.contentText,),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: friendSearchCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Search Friend',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black,),
                        onPressed: searchFriend,
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 5.0,
                      children: selectedFriends.map((friend) {
                        return Chip(
                          label: Text(friend['name']),
                          backgroundColor: design.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedFriends.remove(friend);
                            });
                          },
                          deleteIconColor: Colors.red,
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 15),

                  filteredFriends.isEmpty
                      ? Center(
                    child: Text(
                      'Friend not found',
                    ),
                  )
                      : Align(
                    alignment: Alignment.centerLeft, // Align to the left
                    child: Container(
                      width: 235,
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      decoration: BoxDecoration(
                        color: design.secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: design.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          return Column(
                            children: [
                              ListTile(
                                visualDensity: VisualDensity(vertical: -3),
                                title: Text(friend['name']),
                                onTap: () => selectFriend(friend),
                              ),
                              if (index != filteredFriends.length - 1)
                                Divider(
                                  color: design.primaryColor,
                                  thickness: 2,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 40,),

                  widget.goalType == "create"
                    ? Text(_errorMsg, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,color: Colors.red), textAlign: TextAlign.center,)
                    : Text(
                      "Please note that the contributions of a removed member will also be deleted.",
                      style: design.captionText,
                      textAlign: TextAlign.center,
                    ),

                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _errorMsg = "";
                      });
                      if (_formKey.currentState!.validate()) {
                        List<String> selectedFriendID = selectedFriends.map((friend) => friend['uid'] as String).toList();

                        if (widget.goalType == "create") {

                          if(double.parse(targetAmountCtrl.text) < double.parse(constPayAmountCtrl.text)){

                            setState(() {
                              _errorMsg = "Please enter again, your scheduled payment amount cannot exceed your target amount.";
                            });
                            await Future.delayed(Duration(milliseconds: 100));

                            Scrollable.ensureVisible(
                              targetFieldKey.currentContext!,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Your scheduled payment amount cannot exceed your target amount.')),
                            );
                          }else if(_duration <= 1){

                            setState(() {
                              _commitment == "by Daily Amount"
                                  ? _errorMsg = 'Please enter again, your duration to achieve the goal must be more than 1 day.'
                                  : _errorMsg = 'Please enter again, your duration to achieve the goal must be more than 1 month.';
                            });
                            Scrollable.ensureVisible(
                              targetFieldKey.currentContext!,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            Scrollable.ensureVisible(
                              targetFieldKey.currentContext!,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_commitment == "by Daily Amount"
                                  ?'Your duration to achieve the goal must be more than 1 day.'
                                  :'Your duration to achieve the goal must be more than 1 month.'
                              )
                              ),
                            );
                          }else{
                            setState(() {
                              _errorMsg = "";
                            });

                            addGoal(
                                goalNameCtrl.text,
                                goalDescCtrl.text,
                                double.parse(targetAmountCtrl.text),
                                _commitment!,
                                double.parse(constPayAmountCtrl.text),
                                _duration.toInt(),
                                selectedFriendID
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Goal Created Successfully')),
                            );

                            Navigator.pop(context);

                          }

                        } else {
                          editGoal(
                            goalNameCtrl.text,
                            goalDescCtrl.text,
                            selectedFriendID
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Goal Updated Successfully')),
                          );

                          await waitFunc(widget.goalID);

                          Navigator.pop(context);
                        }


                      }else{

                        if (nameFieldKey.currentState?.hasError == true) {
                          Scrollable.ensureVisible(
                            nameFieldKey.currentContext!,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else if (targetFieldKey.currentState?.hasError == true) {
                          Scrollable.ensureVisible(
                            targetFieldKey.currentContext!,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else if (payFieldKey.currentState?.hasError == true) {
                          Scrollable.ensureVisible(
                            payFieldKey.currentContext!,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Form validation failed. Please check your inputs.')),
                        );
                      }
                    },
                    child: Text(widget.goalType == "create" ? "Create" : "Save", style: design.contentText,),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(150, 45),
                      backgroundColor: design.primaryColor,
                      foregroundColor: Colors.black,
                    ).copyWith(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}
