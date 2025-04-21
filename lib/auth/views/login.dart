import 'package:caching/auth/auth_service.dart';
import 'package:caching/auth/views/register.dart';
import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final design = Design();
  final TextEditingController loginEmailCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();

  void login() async{
    final _auth = AuthService();

    try{
      await _auth.signInWithEmailPassword(loginEmailCtrl.text, loginPasswordCtrl.text);
    }catch (e){
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(e.toString()),
      ));
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Login', style: design.titleText),

              //Email input
              TextField(
                controller: loginEmailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email"
                ),
              ),

              //Password Input
              TextField(
                obscureText: true,
                controller: loginPasswordCtrl,
                decoration: const InputDecoration(
                    labelText: "Password",
                ),
              ),

              //Login Button
              ElevatedButton(
                  onPressed: login,
                  child: Text("Login")
              ),
              ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                    },
                  child: Text("Register")
              )
            ],
          ),
        ),
      ),
    );
  }
}
