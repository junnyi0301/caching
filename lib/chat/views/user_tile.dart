import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String name;
  final void Function()? onTap;
  final void Function()? unfriend;
  const UserTile({super.key, required this.text, required this.onTap, required this.name, required this.unfriend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person)
          ),
          title: Text(name),
          subtitle: Text(text),
          trailing: Container(
              decoration:BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
              child: IconButton(onPressed: unfriend, icon: Icon(Icons.close))
          ),
        )
    );
  }
}
