import 'package:flutter/material.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key, required this.title});

  final String title;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Text("Hello World"),
            Text("You create your page here")
          ],
        ),
      ),
    );
  }
}
