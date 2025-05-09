import 'package:caching/auth/auth_gate.dart';
import 'package:caching/goal/views/goal_page.dart';
import 'package:caching/checklist/views/checklist_page.dart';
import 'package:caching/cashflow/views/analysis.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:caching/users/views/profile_page.dart';
import 'package:caching/utilities/design.dart';
import 'package:flutter/material.dart';

final design = Design();

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Important to allow overflow
      children: [
        // Background bar
        Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: design.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(context, Icons.list_alt, 0, "Goals", iconSize: 28),
              _navIcon(context, Icons.draw, 1, "Checklist", iconSize: 28),
              const SizedBox(width: 40),
              _navIcon(context, Icons.people, 3, "Friends", iconSize: 28),
              _navIcon(context, Icons.person, 4, "Profile", iconSize: 28),
            ],
          ),
        ),

        // Floating center button (placed after to appear on top)
        Positioned(
          top: -20, // Pull it upward above the bar
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: GestureDetector(
            onTap: () {
              if (currentIndex != 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => AnalysisPg(),
                ));
              }
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: design.primaryButton,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 30,
                color: currentIndex == 2 ? design.secondaryButton : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, int index, String label, {double iconSize = 25.0}) {
    return GestureDetector(
      onTap: () {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GoalPage()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChecklistPage()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FriendsPage()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: currentIndex == index ? design.secondaryButton : Colors.black),
          Text(label, style: TextStyle(fontSize: 12, color: currentIndex == index ? design.secondaryButton : Colors.black)),
        ],
      ),
    );
  }

}