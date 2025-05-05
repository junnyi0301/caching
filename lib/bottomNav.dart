import 'package:caching/auth/auth_gate.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:caching/goal/views/goal_page.dart';
import 'package:caching/cashflow/views/analysis.dart';
import 'package:caching/utilities/design.dart';
import 'package:flutter/material.dart';

final design = Design();

class BottomNav extends StatefulWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.draw), label: "Checklist"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: design.secondaryButton,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == widget.currentIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => GoalPage(),
            ));
          } else if (index == 1) {
            // Navigator.pushReplacement(context, MaterialPageRoute(
            //   builder: (context) => ChecklistPage(),
            // ));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => AnalysisPg(),
            ));
          } else if (index == 3){
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => FriendsPage(),
            ));
          } else if (index == 4){
            // Navigator.pushReplacement(context, MaterialPageRoute(
            //   builder: (context) => ProfilePage(),
            // ));
          }
        }
    );
  }
}