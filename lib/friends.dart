import 'package:caching/friends_provider.dart';
import 'package:caching/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design.dart';

final List<User> userList = [
  User(1, "Darren", 21),
  User(2, "Alice", 22),
  User(3, "Michael", 23),
  User(4, "Nicholas", 24),
  User(5, "Katerine", 25),
  User(6, "Harry", 20),
];

final design = Design();

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Friends", style: design.poppins),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(itemBuilder: (BuildContext context, int index){
                return FriendCard(userList: userList, index: index);
              }, separatorBuilder: (BuildContext context, int index){
                return Divider();
              }, itemCount: userList.length),
            )
          ],
        ),
      ),
    );
  }
}
