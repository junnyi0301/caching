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
  late var waitRun;

  List<TextEditingController> itemCtrl = [];

  @override
  void initState(){
    super.initState();
    _addItem();

    if(widget.checklistType == "edit"){
      loadChecklistData();
    }
  }

  Future<void> waitFunc(String checklistID) async{
    waitRun = await _checkListService.getSpecificChecklist(checklistID);
    print(waitRun);
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
    String checklistID;

    if (title.trim().isEmpty){
      title = "";
    }

    for(int i = 0; i < itemCtrl.length; i ++){
      items.add(itemCtrl[i].text);
    }

    if(_reminder == 1){

      checklistID = await _checkListService.addNewChecklist(title, date, items);

    }else{

      checklistID = await _checkListService.addNewChecklist(title, "", items);

    }

    await waitFunc(checklistID);

  }

  void loadChecklistData() async{
    Map<String, dynamic> checklistData = await _checkListService.getSpecificChecklist(widget.checklistID);
    Map<String, dynamic> itemData = await _checkListService.getSpecificChecklistItem(widget.checklistID);

    setState(() {
      checklistTitleCtrl.text = checklistData["ChecklistTitle"];
      checklistReminderDateCtrl.text = checklistData["ChecklistDate"];

      if(checklistReminderDateCtrl.text.isEmpty){
        _reminder = 2;
      }

      itemCtrl.clear();

      itemData.forEach((key, value) {
        if(value["ItemStatus"] != "Inactive"){
          TextEditingController controller = TextEditingController(text: value["ItemName"]);
          itemCtrl.add(controller);
        }
      });

    });

  }

  Future<void> editChecklist() async{
    List<String> item = [];
    await _checkListService.updateChecklistTitle(widget.checklistID, checklistTitleCtrl.text);

    if(_reminder == 1){
      print("run reminder 1");
      await _checkListService.updateChecklistDate(widget.checklistID, checklistReminderDateCtrl.text);
    }else{
      await _checkListService.updateChecklistDate(widget.checklistID, "");
    }

    for(int i = 0; i < itemCtrl.length; i ++){
      item.add(itemCtrl[i].text);
    }
    await _checkListService.updateItem(widget.checklistID, item);
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

                    widget.checklistType== "create"
                      ? Text("Create Checklist", style: design.subtitleText,)
                      : Text("Edit Checklist", style: design.subtitleText,),

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

                    _reminder == 1? SizedBox(height: 20): SizedBox(height: 0),

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

                    _reminder == 1? SizedBox(height: 20): SizedBox(height: 0),

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
                                    SnackBar(content: Text('Checklist Created Successfully.')),
                                  );

                                  Navigator.pop(context);

                                } else {

                                  if(itemCtrl.isNotEmpty){
                                    await editChecklist();

                                    await waitFunc(widget.checklistID);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Checklist Updated Successfully.')),
                                    );

                                    Navigator.pop(context);
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please contain at least 1 item in checklist.')),
                                    );
                                  }
                                }
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
