import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text("First Letter"),
        ),
        title: Text("Name"),
        subtitle: Text(""),
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
