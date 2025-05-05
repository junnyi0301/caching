import 'package:caching/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/auth/auth_service.dart';
import 'package:caching/checklist/views/create_checklist_page.dart';
import 'package:caching/checklist/services/checklist_service.dart';
import 'checklist_block.dart';
import 'package:caching/utilities/noti_service.dart';

final design = Design();

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final AuthService _authService = AuthService();
  final ChecklistService _checklistService = ChecklistService();
  final notiService = NotiService();

  List<Map<String, dynamic>> allChecklist = [];

  @override
  void initState(){
    super.initState();
    loadChecklist();
  }

  void logout() {
    _authService.signOut();
  }

  void loadChecklist() async{
    allChecklist = await _checklistService.getAllChecklist();
    setState(() {

    });
  }

  void trying() async{
    await NotiService().scheduleTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: design.primaryColor,
        title: Text("Checklist", style: design.subtitleText),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 290,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateChecklistPage(checklistType: "create", checklistID: " "),
                      ),
                    ).then((_) {
                      loadChecklist();
                    });
                  },
                  child: Text('Create New Checklist', style: design.contentText),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: design.primaryColor,
                    foregroundColor: Colors.black,
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text("Your Checklist", style: design.contentText),
              allChecklist.isEmpty
                ? Text("Create a checklist now.")
                : Expanded(
                  child: Container(
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: allChecklist.length,
                      itemBuilder: (context, index){
                        var checklist = allChecklist[index];
                        return ChecklistBlock(
                            checklistID: checklist["ChecklistID"],
                            checklistTitle: checklist["ChecklistTitle"],
                            checklistDate: checklist["ChecklistDate"],
                            checklistStatus: checklist["ChecklistStatus"],
                            itemList: checklist["ItemList"] ?? {},
                            reload: () => loadChecklist()
                        );
                      },
                    ),
                  )
              ),

              ElevatedButton(onPressed: (){

                logout();

              }, child: Text("Logout")),

              ElevatedButton(
                onPressed: () async {
                  try {
                    await NotiService().scheduleNotification(
                      title: "Reminder",
                      body: "Don't forget your task!",
                      hour: 6,
                      minute: 03,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notification scheduled successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                  await NotiService().debugPrintPendingNotifications();
                },
                child: Text("Schedule Notification"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

