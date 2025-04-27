import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design.dart';
import 'goal.dart';

final design = Design();

class CreateGoal extends StatefulWidget {
  const CreateGoal({super.key});

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  final goalNameCtrl = TextEditingController();
  final goalDescCtrl = TextEditingController();
  final targetAmountCtrl = TextEditingController();

  final int _commitment = 1;
  final _commitmentList = ['by Daily Amount', 'by Monthly Amount'];

  final constPayAmountCtrl = TextEditingController(); // can be daily or monthly
  final durationCtrl = TextEditingController();

  final _myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        title: Text("Create Goal", style: design.subtitleText),
        centerTitle: true,

        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: design.secondaryColor,
            borderRadius: BorderRadius.circular(8)
          ),

          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: (){
              Navigator.pop(context);
            }
          )

        )
      ),
      body: Container(
        color: design.secondaryColor,
        padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
        child: Center(
          child: Column(

            children: [
              Text('Create Goal', style: design.subtitleText,),

              TextFormField(
                controller: goalNameCtrl,
                keyboardType: TextInputType.text,
                focusNode: _myFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Goal Name*'
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter goal name.';
                  } else if (value.length > 15){
                    return 'Please enter within 15 words';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: goalDescCtrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Goal Description'
                ),
              ),

              TextFormField(
                controller: targetAmountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Target Amount*',
                  prefixText: 'RM '
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter target amount.';
                  } else {
                    if (double.parse(value) <= 0){
                      return 'Target amount should not be negative or 0';
                    }
                  }
                  return null;
                },
              ),

              DropdownButtonFormField(
                value: _commitment,
                items: _commitmentList.map((int item){
                  return DropdownMenuItem(  value: item, child: Text('$item'));
                }).toList(),
                onChanged: (int? item){
                  setState(() {
                    _commitment = item;
                  });
                },
                validator: (value){
                  if (value == 0){
                    return 'Please select an option.';
                  }
                  return null;
                },
                )

            ],

          ),
        ),
      )
    );
  }
}


