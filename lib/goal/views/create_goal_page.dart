import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/services/goal_service.dart';

final design = Design();

class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({super.key});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final GoalService _goalService = GoalService();

  final goalNameCtrl = TextEditingController();
  final goalDescCtrl = TextEditingController();
  final targetAmountCtrl = TextEditingController();
  final constPayAmountCtrl = TextEditingController();
  final friendSearchCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _commitment = 'by Daily Amount';
  final _commitmentList = ['by Daily Amount', 'by Monthly Amount'];

  double _duration = 0;
  List<Map<String, dynamic>> allFriends = []; // All friends from firebase
  List<Map<String, dynamic>> filteredFriends = []; // Displayed friends
  List<Map<String, dynamic>> selectedFriends = []; // Selected friends

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  void calcDuration() {
    double target = double.tryParse(targetAmountCtrl.text) ?? 0;
    double pay = double.tryParse(constPayAmountCtrl.text) ?? 1;
    setState(() {
      _duration = target / pay;
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
    if (!selectedFriends.contains(friend)) {
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
        title: Text("Create Goal", style: design.subtitleText),
        centerTitle: true,
      ),
      body: Container(
        color: design.secondaryColor,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [

                TextFormField(
                  controller: goalNameCtrl,
                  decoration: const InputDecoration(labelText: 'Goal Name*'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter goal name.';
                    } else if (value.length > 15) {
                      return 'Please enter within 15 words';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: goalDescCtrl,
                  decoration: const InputDecoration(labelText: 'Goal Description'),
                ),

                TextFormField(
                  controller: targetAmountCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Target Amount*',
                    prefixText: 'RM ',
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
                  onChanged: (String? value) {
                    setState(() {
                      _commitment = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select commitment' : null,
                ),

                TextFormField(
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pay amount.';
                    }
                    return null;
                  },
                  onChanged: (_) => calcDuration(),
                ),

                const SizedBox(height: 20),
                Text(
                  _commitment == 'by Daily Amount'
                      ? "Duration: ${_duration.toStringAsFixed(0)} day(s)"
                      : "Duration: ${_duration.toStringAsFixed(0)} month(s)",
                ),
                const SizedBox(height: 20),

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
                      icon: const Icon(Icons.search),
                      onPressed: searchFriend,
                    ),
                  ],
                ),

                Wrap(
                  spacing: 8.0,
                  children: selectedFriends.map((friend) {
                    return Chip(
                      label: Text(friend['name']),
                      onDeleted: () {
                        setState(() {
                          selectedFriends.remove(friend);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                filteredFriends.isEmpty
                    ? Center(child: Text('Friend not found'))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return ListTile(
                      title: Text(friend['name']),
                      onTap: () => selectFriend(friend),
                    );
                  },
                ),

                ElevatedButton(

                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      List<String> selectedFriendIDs = selectedFriends.map((friend) => friend['uid'] as String).toList();
                      addGoal(
                        goalNameCtrl.text,
                        goalDescCtrl.text,
                        double.parse(targetAmountCtrl.text),
                        _commitment!,
                        double.parse(constPayAmountCtrl.text),
                        _duration.toInt(),
                        selectedFriendIDs
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Goal Created Successfully'),)
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Create Goal")
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
