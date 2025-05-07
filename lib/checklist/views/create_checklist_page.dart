import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/checklist/services/checklist_service.dart';
import 'package:intl/intl.dart';
import 'package:caching/utilities/notification.dart';
import 'package:permission_handler/permission_handler.dart';

final design = Design();
final ChecklistService _checklistService = ChecklistService();

final notificationService = NotificationService();

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

class _CreateChecklistPageState extends State<CreateChecklistPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  final checklistTitleCtrl = TextEditingController();
  final checklistReminderDateCtrl = TextEditingController();
  int _reminder = 1;
  late var waitRun;

  List<TextEditingController> itemCtrl = [];

  final GlobalKey<FormFieldState> titleFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dateFieldKey = GlobalKey<FormFieldState>();

  bool _checkingPermissionAfterSettings = false;


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addItem();

    if(widget.checklistType == "edit"){
      loadChecklistData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> waitFunc(String checklistID) async{
    waitRun = await _checklistService.getSpecificChecklist(checklistID);
    print(waitRun);
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
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

      checklistID = await _checklistService.addNewChecklist(title, date, items);

    }else{

      checklistID = await _checklistService.addNewChecklist(title, "", items);

    }

    await _checklistService.updateChecklistReminder(checklistID);
    await waitFunc(checklistID);

  }

  void loadChecklistData() async{
    Map<String, dynamic> checklistData = await _checklistService.getSpecificChecklist(widget.checklistID);
    Map<String, dynamic> itemData = await _checklistService.getSpecificChecklistItem(widget.checklistID);

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
    await _checklistService.updateChecklistTitle(widget.checklistID, checklistTitleCtrl.text);

    if(_reminder == 1){
      await _checklistService.updateChecklistDate(widget.checklistID, checklistReminderDateCtrl.text);
    }else{
      await _checklistService.updateChecklistDate(widget.checklistID, "");
    }

    for(int i = 0; i < itemCtrl.length; i ++){
      item.add(itemCtrl[i].text);
    }

    await _checklistService.updateItem(widget.checklistID, item);
    await _checklistService.updateChecklistReminder(widget.checklistID);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_checkingPermissionAfterSettings && state == AppLifecycleState.resumed) {
      // User returned from settings, check permission again
      notificationService.requestNotificationPermission().then((granted) {
        if (granted) {
          // Permission granted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notification permission granted!")),
          );
        } else {
          // Still denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notification permission still denied.")),
          );
        }

        _checkingPermissionAfterSettings = false;
      });
    }
  }

  Future<bool> _handlePermissionRequest() async {
    bool granted = await notificationService.requestNotificationPermission();

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redirecting to settings...")),
      );
      _checkingPermissionAfterSettings = true;
      openAppSettings();

      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
          iconSize: 30,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            minimumSize: WidgetStatePropertyAll(Size(36, 36)),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
            ),
          ),
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

                    Text("Please add at least one item to create the checklist.", style: design.captionText, textAlign: TextAlign.center),

                    SizedBox(height: 10),

                    TextFormField(
                      key: titleFieldKey,
                      controller: checklistTitleCtrl,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Checklist Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return "Please enter a checklist title.";
                        } else if (value.length > 15) {
                          return 'Please enter within 15 words';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 30),

                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder', style: TextStyle(fontSize: 18, color: Colors.black54),),
                          Text("The notification will be sent on the selected date at 9 AM.", style: design.captionText, textAlign: TextAlign.left),
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

                    _reminder == 1? SizedBox(height: 15): SizedBox(height: 0),

                    _reminder == 1
                      ?TextFormField(
                        key: dateFieldKey,
                        controller: checklistReminderDateCtrl,
                        decoration: InputDecoration(
                          labelText: "Remind Date*",
                          labelStyle: TextStyle(
                            fontSize: 18,
                          ),
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

                    _reminder == 1? SizedBox(height: 25): SizedBox(height: 0),

                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text("Items", style: TextStyle(fontSize: 18, color: Colors.black54)),

                              ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: Icon(Icons.add, color: Colors.black),
                                label: Text("Add Item"),
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(130, 30),
                                  backgroundColor: design.primaryColor,
                                  foregroundColor: Colors.black,
                                )
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
                                          hintText: 'Enter item',
                                          border: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: itemCtrl[index].text.isEmpty ? Colors.grey : Colors.blueAccent,
                                              width: 1.5
                                            ),
                                          ),
                                        ),
                                        style: TextStyle(color: Colors.black), // Text color
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
                          )

                        ],
                      ),
                    ),

                    SizedBox(height: 50),

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

                                if (_reminder == 1) {

                                  DateTime today = DateTime.now();
                                  DateTime tomorrow = DateTime(today.year, today.month, today.day).add(Duration(days: 1));
                                  DateTime dateSetted = DateTime.parse(checklistReminderDateCtrl.text);

                                  if (dateSetted.isBefore(tomorrow)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Reminder already executed. Please change the reminder date or cancel the reminder."),
                                      ),
                                    );
                                    return;
                                  }

                                  print("Run Notification");

                                  bool proceed = await _handlePermissionRequest();
                                  if(proceed == false){
                                    return;
                                  }

                                  NotificationService().cancelAllNotification();

                                  await NotificationService().directShowNotification(
                                    title: "Cachingg Checklist Reminder",
                                    body: "You had set a reminder on ${checklistReminderDateCtrl.text}. Click to check more.",
                                  );

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

                              }else{

                                if (titleFieldKey.currentState?.hasError == true) {
                                  Scrollable.ensureVisible(
                                    titleFieldKey.currentContext!,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else if (dateFieldKey.currentState?.hasError == true) {
                                  Scrollable.ensureVisible(
                                    dateFieldKey.currentContext!,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Form validation failed. Please check your inputs.')),
                                );
                              }
                            },
                            child: Text(widget.checklistType == "create" ? "Create" : "Save", style: design.contentText,),
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
