import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/views/create_checklist_page.dart';

final design = Design();
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        title: Text("Check List", style: design.subtitleText),
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
                    context, MaterialPageRoute(builder: (context) => CreateChecklistPage())
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

