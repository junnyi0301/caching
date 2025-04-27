import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/goal/services/checklist_service.dart';

final design = Design();

class CreateChecklistPage extends StatefulWidget {
  const CreateChecklistPage({super.key});

  @override
  State<CreateChecklistPage> createState() => _CreateChecklistPageState();
}

class _CreateChecklistPageState extends State<CreateChecklistPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
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


              ],
            ),
          ),
        ),
      ),
    );
  }
}
