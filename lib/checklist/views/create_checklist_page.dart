import 'package:caching/checklist/views/checklist_page.dart';
import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/checklist/services/checklist_service.dart';
import 'package:intl/intl.dart';

final design = Design();
final ChecklistService _checkListService = ChecklistService();

class CreateChecklistPage extends StatefulWidget {
  final String checklistType;
  final String checklistID;

    const CreateChecklistPage({
      super.key,
      required this.checklistType,
      required this.checklistID
    });

  @override
  State<CreateChecklistPage> createState() => _CreateChecklistPageState();
}

class _CreateChecklistPageState extends State<CreateChecklistPage> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  final checklistTitleCtrl = TextEditingController();
  final checklistReminderDateCtrl = TextEditingController();
  int _reminder = 1;

  List<TextEditingController> itemCtrl = [];

  @override
  void initState(){
    super.initState();
    _addItem();
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );

    if (_picked != null) {
      setState(() {
        checklistReminderDateCtrl.text = DateFormat('yyyy-MM-dd').format(_picked);
      });
    }
  }

  void _addItem() {
    if (itemCtrl.isEmpty || itemCtrl.last.text.isNotEmpty) {
      setState(() {
        itemCtrl.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in the last item before adding a new one.')),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      itemCtrl.removeAt(index);
    });
  }

  void addChecklist() async{
    String title = checklistTitleCtrl.text;
    String date = checklistReminderDateCtrl.text;
    List<String> items = [];

    if (title.trim().isEmpty){
      title = "";
    }

    for(int i = 0; i < itemCtrl.length; i ++){
      items.add(itemCtrl[i].text);
    }

    if(_reminder == 1){

      await _checkListService.addNewChecklist(title, date, items);

    }else{

      await _checkListService.addNewChecklist(title, "", items);

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
        title: widget.checklistType == "create"? Text("Create Checklist", style: design.subtitleText)
            : Text("Edit Checklist", style: design.subtitleText),
        centerTitle: true,
      ),
      body: Container(
          color: design.secondaryColor,
          padding: const EdgeInsets.all(20),
          height: double.infinity,
          child: Container(
            color: design.primaryButton,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Text("Create Checklist", style: design.subtitleText,),

                    SizedBox(height: 10),

                    TextFormField(
                      controller: checklistTitleCtrl,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(labelText: 'Checklist Title'),
                      validator: (value) {
                        if (value!.length > 15) {
                          return 'Please enter within 15 words';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder',),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: Text('Yes'),
                                  value: 1,
                                  groupValue: _reminder,
                                  onChanged: (value) {
                                    setState(() {
                                      _reminder = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: Text('No'),
                                  value: 2,
                                  groupValue: _reminder,
                                  onChanged: (value) {
                                    setState(() {
                                      _reminder = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    _reminder == 1
                      ?TextFormField(
                        controller: checklistReminderDateCtrl,
                        decoration: InputDecoration(
                          labelText: "Remind Date*",
                          prefixIcon: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide.none
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.blueAccent)
                          )
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                        validator:(value){
                          if(_reminder ==1 && (value == null || value.isEmpty)){
                            return "Please select a reminder date.";
                          }
                          return null;
                        },
                      )
                      :Text(""),

                    SizedBox(height: 20),

                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text("Items"),

                              ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: Icon(Icons.add),
                                label: Text("Add Item"),
                              )

                            ],
                          ),

                          SizedBox(height: 10),

                          Column(
                            children: List.generate(itemCtrl.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: itemCtrl[index],
                                        decoration: InputDecoration(
                                          labelText: 'Item ${index + 1}',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {

                                if (!itemCtrl.any((ctrl) => ctrl.text.trim().isNotEmpty)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please add at least one item to create checklist.')),
                                  );
                                  return;
                                }

                                if (widget.checklistType == "create") {

                                  addChecklist();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Checklist Created Successfully')),
                                  );

                                } else {

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Checklist Updated Successfully')),
                                  );
                                }

                                Navigator.pushReplacement<void, void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => const ChecklistPage(),
                                  ),
                                );
                              }
                            },
                            child: Text(widget.checklistType == "create" ? "Create Checklist" : "Save"),
                          )
                        ],
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
