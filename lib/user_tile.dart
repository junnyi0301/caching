import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person)
          ),
          title: Text("Name"),
          subtitle: Text(text),
        )
    );
  }
}
