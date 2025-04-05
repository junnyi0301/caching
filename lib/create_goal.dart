import 'package:flutter/material.dart';
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
  final commitmentCtrl = TextEditingController();
  final monthlyAmountCtrl = TextEditingController();
  final durationCtrl = TextEditingController();

  final _myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        title: Text("Create Goal", style: design.subtitleText),
        centerTitle: true,

        // leadingWidth: 60,
        // leading: ElevatedButton.icon(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: design.secondaryColor,
        //     elevation: 0,
        //     padding: const EdgeInsets.all(1),
        //     minimumSize: const Size(40, 40),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        //   icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
        //   label: const Text(""),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),

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
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: design.primaryButton,
                border: Border.all(width: 3, color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(child: Text("Create Goal", style: design.subtitleText)),
                  const SizedBox(height: 20),

                  //Goal Name
                  Text("Goal Name: *", style: design.contentText,),
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: 'Enter Here.',
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 3),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    controller: goalNameCtrl,
                    focusNode: _myFocusNode,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Pleas enter Goal Name.';
                      }else if(value.length > 15){
                        return 'Please enter not more than 15 character.';
                      }else{
                        return null;
                      }
                    },
                  ),

                ],
              ),

            ),
          ),
        ),
      )
    );
  }
}


