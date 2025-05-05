import 'package:caching/auth/auth_gate.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:caching/checklist/views/checklist_page.dart';
import 'package:caching/goal/views/create_goal_page.dart';
import 'package:caching/goal/views/goal_page.dart';
import 'package:flutter/material.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.draw), label: "Checklist")
        ],
        currentIndex: widget.currentIndex,
          onTap: (index) {
            if (index == widget.currentIndex) return;

            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => FriendsPage(), // includes BottomNavBar
              ));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => GoalPage(), // also includes BottomNavBar
              ));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => ChecklistPage(), // also includes BottomNavBar
              ));
            }
          }
    );
  }
}
