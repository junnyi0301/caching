import 'package:caching/auth/views/login.dart';
import 'package:caching/chat/views/friends.dart';
import 'package:caching/goal/views/goal_page.dart';
import 'package:caching/rewards/view/redeemed.dart';
import 'package:caching/rewards/view/rewards_details.dart';
import 'package:caching/users/views/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:caching/cashflow/views/analysis.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            // user id logged in
            if(snapshot.hasData){
              return const AnalysisPg();
            }else{
              //To login page
              return const LoginPage();
            }
          }
      ),
    );
  }
}
