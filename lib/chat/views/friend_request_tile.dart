import 'package:flutter/material.dart';

class FriendRequestTile extends StatelessWidget {
  final String text;
  final String name;
  final void Function()? accept;
  final void Function()? decline;

  const FriendRequestTile({super.key, required this.text, required this.accept, required this.decline, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person)
      ),
      title: Text(name),
      subtitle: Text(text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              decoration:BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
              ),
              child: IconButton(onPressed: accept, icon: Icon(Icons.check))
          ),
          SizedBox(width: 8,),
          Container(
              decoration:BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
              child: IconButton(onPressed: decline, icon: Icon(Icons.close))
          ),
        ],
      ),
    );
  }
}
