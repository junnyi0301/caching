import 'package:flutter/material.dart';
import 'user.dart';
import 'message_window.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.userList, required this.index});

  final List<User> userList;
  final int index;

  @override
  Widget build(BuildContext context) {
    var user = userList[index];
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessageWindow(id: user.id)));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(user.name[0]),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Age: ${user.age}"),
        trailing: ElevatedButton(
          onPressed: () {
            // Handle button action
          },
          child: const Text("Button"),
        ),
      )
    );
  }
}
