import 'package:flutter/material.dart';

class MessageWindow extends StatefulWidget {
  final int id;

  const MessageWindow({super.key, required this.id});

  @override
  State<MessageWindow> createState() => _MessageWindowState();
}

class _MessageWindowState extends State<MessageWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Friends"),
      ),
    );
  }
}
