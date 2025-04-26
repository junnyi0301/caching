import 'package:flutter/material.dart';

class AddFriendTile extends StatelessWidget {
  final String name;
  final Function()? onTap;
  final bool isFriend;
  const AddFriendTile({super.key, required this.name, required this.onTap, required this.isFriend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person)
      ),
      title: Text(name),
      trailing: ElevatedButton(onPressed: isFriend ? (){} : onTap, child: isFriend ? Text("Added") : Text("Add Friend"),),
    );
  }
}
