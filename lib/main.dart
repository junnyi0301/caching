import 'package:caching/auth/views/login.dart';
import 'package:caching/utilities/firebase_options.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(231, 238, 253, 1)),
          useMaterial3: true,
        ),
        home: const AuthGate()
        //Don't create your page in main.dart
        //Leave the main as it is right now and create a new file
        //Change const ExamplePage(title: 'Example') to your page for easier integration
        );
  }
}
