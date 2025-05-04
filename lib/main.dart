import 'package:caching/auth/auth_gate.dart';
import 'package:caching/auth/views/login.dart';
import 'package:caching/bottomNav.dart';
import 'package:caching/utilities/firebase_options.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:caching/utilities/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService().initNotification();
  tz.initializeTimeZones();

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
    );
  }
}
